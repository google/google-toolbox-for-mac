//
//  GTMLogger.m
//
//  Copyright 2007-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#if !__has_feature(objc_arc)
#error "This file needs to be compiled with ARC enabled."
#endif

#import "GTMLogger.h"
#import <fcntl.h>
#import <unistd.h>
#import <stdlib.h>
#import <pthread.h>


#if !defined(__clang__) && (__GNUC__*10+__GNUC_MINOR__ >= 42)
// Some versions of GCC (4.2 and below AFAIK) aren't great about supporting
// -Wmissing-format-attribute
// when the function is anything more complex than foo(NSString *fmt, ...).
// You see the error inside the function when you turn ... into va_args and
// attempt to call another function (like vsprintf for example).
// So we just shut off the warning for this file. We reenable it at the end.
#pragma GCC diagnostic ignored "-Wmissing-format-attribute"
#endif  // !__clang__

// Reference to the shared GTMLogger instance. This is not a singleton, it's
// just an easy reference to one shared instance.
static GTMLogger *gSharedLogger = nil;


@implementation GTMLogger

// Returns a pointer to the shared logger instance. If none exists, a standard
// logger is created and returned.
+ (instancetype)sharedLogger {
  @synchronized(self) {
    if (gSharedLogger == nil) {
      gSharedLogger = [self standardLogger];
    }
    return gSharedLogger;
  }
}

+ (void)setSharedLogger:(GTMLogger *)logger {
  @synchronized(self) {
    gSharedLogger = logger;
  }
}

+ (instancetype)standardLogger {
  // Don't trust NSFileHandle not to throw
  @try {
    id<GTMLogWriter> writer = [NSFileHandle fileHandleWithStandardOutput];
    id<GTMLogFormatter> fr = [[GTMLogStandardFormatter alloc] init];
    id<GTMLogFilter> filter = [[GTMLogLevelFilter alloc] init];
    return [[self alloc] initWithWriter:writer
                               formatter:fr
                                  filter:filter];
  }
  @catch (id e) {
    // Ignored
  }
  return nil;
}

+ (instancetype)standardLoggerWithStderr {
  // Don't trust NSFileHandle not to throw
  @try {
    id me = [self standardLogger];
    [me setWriter:[NSFileHandle fileHandleWithStandardError]];
    return me;
  }
  @catch (id e) {
    // Ignored
  }
  return nil;
}

+ (instancetype)standardLoggerWithStdoutAndStderr {
  // We're going to take advantage of the GTMLogger to GTMLogWriter adaptor
  // and create a composite logger that an outer "standard" logger can use
  // as a writer. Our inner loggers should apply no formatting since the main
  // logger does that and we want the caller to be able to change formatters
  // or add writers without knowing the inner structure of our composite.

  // Don't trust NSFileHandle not to throw
  @try {
    GTMLogBasicFormatter *formatter = [[GTMLogBasicFormatter alloc] init];
    GTMLogger *stdoutLogger =
        [self loggerWithWriter:[NSFileHandle fileHandleWithStandardOutput]
                     formatter:formatter
                        filter:[[GTMLogMaximumLevelFilter alloc]
                                  initWithMaximumLevel:kGTMLoggerLevelInfo]
        ];
    GTMLogger *stderrLogger =
        [self loggerWithWriter:[NSFileHandle fileHandleWithStandardError]
                     formatter:formatter
                        filter:[[GTMLogMininumLevelFilter alloc]
                                  initWithMinimumLevel:kGTMLoggerLevelError]];
    GTMLogger *compositeWriter =
        [self loggerWithWriter:[NSArray arrayWithObjects:
                                   stdoutLogger, stderrLogger, nil]
                     formatter:formatter
                        filter:[[GTMLogNoFilter alloc] init]];
    GTMLogger *outerLogger = [self standardLogger];
    [outerLogger setWriter:compositeWriter];
    return outerLogger;
  }
  @catch (id e) {
    // Ignored
  }
  return nil;
}

+ (instancetype)standardLoggerWithPath:(NSString *)path {
  @try {
    NSFileHandle *fh = [NSFileHandle fileHandleForLoggingAtPath:path mode:0644];
    if (fh == nil) return nil;
    id me = [self standardLogger];
    [me setWriter:fh];
    return me;
  }
  @catch (id e) {
    // Ignored
  }
  return nil;
}

+ (instancetype)loggerWithWriter:(id<GTMLogWriter>)writer
                       formatter:(id<GTMLogFormatter>)formatter
                          filter:(id<GTMLogFilter>)filter {
  return [[self alloc] initWithWriter:writer
                             formatter:formatter
                                filter:filter];
}

+ (instancetype)logger {
  return [[self alloc] init];
}

- (instancetype)init {
  return [self initWithWriter:nil formatter:nil filter:nil];
}

- (instancetype)initWithWriter:(id<GTMLogWriter>)writer
                     formatter:(id<GTMLogFormatter>)formatter
                        filter:(id<GTMLogFilter>)filter {
  if ((self = [super init])) {
    [self setWriter:writer];
    [self setFormatter:formatter];
    [self setFilter:filter];
  }
  return self;
}

- (void)dealloc {
  // Unlikely, but |writer_| may be an NSFileHandle, which can throw
  @try {
    [self notifyFilterBeforeDetachIfNeeded];
  }
  @catch (id e) {
    // Ignored
  }
}

- (id<GTMLogWriter>)writer {
  return writer_;
}

- (void)setWriter:(id<GTMLogWriter>)writer {
  @synchronized(self) {
    writer_ = nil;
    if (writer == nil) {
      // Try to use stdout, but don't trust NSFileHandle
      @try {
        writer_ = [NSFileHandle fileHandleWithStandardOutput];
      }
      @catch (id e) {
        // Leave |writer_| nil
      }
    } else {
      writer_ = writer;
    }
  }
}

- (id<GTMLogFormatter>)formatter {
  return formatter_;
}

- (void)setFormatter:(id<GTMLogFormatter>)formatter {
  @synchronized(self) {
    formatter_ = nil;
    if (formatter == nil) {
      @try {
        formatter_ = [[GTMLogBasicFormatter alloc] init];
      }
      @catch (id e) {
        // Leave |formatter_| nil
      }
    } else {
      formatter_ = formatter;
    }
  }
}

- (id<GTMLogFilter>)filter {
  return filter_;
}

- (void)setFilter:(id<GTMLogFilter>)filter {
  @synchronized(self) {
    [self notifyFilterBeforeDetachIfNeeded];
    filter_ = nil;
    if (filter == nil) {
      @try {
        filter_ = [[GTMLogNoFilter alloc] init];
      }
      @catch (id e) {
        // Leave |filter_| nil
      }
    } else {
      filter_ = filter;
    }
    [self notifyFilterAfterAttachIfNeeded];
  }
}

- (void)notifyFilterBeforeDetachIfNeeded {
  if (![filter_ respondsToSelector:@selector(willDetachFromLogger)]) {
    return;
  }
  [filter_ willDetachFromLogger];
}

- (void)notifyFilterAfterAttachIfNeeded {
  if (![filter_ respondsToSelector:@selector(didAttachToLogger)]) {
    return;
  }
  [filter_ didAttachToLogger];
}

- (void)logDebug:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:NULL format:fmt valist:args level:kGTMLoggerLevelDebug];
  va_end(args);
}

- (void)logInfo:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:NULL format:fmt valist:args level:kGTMLoggerLevelInfo];
  va_end(args);
}

- (void)logError:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:NULL format:fmt valist:args level:kGTMLoggerLevelError];
  va_end(args);
}

- (void)logAssert:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:NULL format:fmt valist:args level:kGTMLoggerLevelAssert];
  va_end(args);
}

@end  // GTMLogger

@implementation GTMLogger (GTMLoggerMacroHelpers)

- (void)logFuncDebug:(const char *)func msg:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:func format:fmt valist:args level:kGTMLoggerLevelDebug];
  va_end(args);
}

- (void)logFuncInfo:(const char *)func msg:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:func format:fmt valist:args level:kGTMLoggerLevelInfo];
  va_end(args);
}

- (void)logFuncError:(const char *)func msg:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:func format:fmt valist:args level:kGTMLoggerLevelError];
  va_end(args);
}

- (void)logFuncAssert:(const char *)func msg:(NSString *)fmt, ... {
  va_list args;
  va_start(args, fmt);
  [self logInternalFunc:func format:fmt valist:args level:kGTMLoggerLevelAssert];
  va_end(args);
}

@end  // GTMLoggerMacroHelpers

@implementation GTMLogger (PrivateMethods)

- (void)logInternalFunc:(const char *)func
                 format:(NSString *)fmt
                 valist:(va_list)args
                  level:(GTMLoggerLevel)level {
  // Primary point where logging happens, logging should never throw, catch
  // everything.
  @try {
    NSString *fname = func ? [NSString stringWithUTF8String:func] : nil;
    NSString *msg = [formatter_ stringForFunc:fname
                                   withFormat:fmt
                                       valist:args
                                        level:level];
    if (msg && [filter_ filterAllowsMessage:msg level:level])
      [writer_ logMessage:msg level:level];
  }
  @catch (id e) {
    // Ignored
  }
}

@end  // PrivateMethods


@implementation NSFileHandle (GTMFileHandleLogWriter)

+ (instancetype)fileHandleForLoggingAtPath:(NSString *)path mode:(mode_t)mode {
  int fd = -1;
  if (path) {
    int flags = O_WRONLY | O_APPEND | O_CREAT;
    fd = open([path fileSystemRepresentation], flags, mode);
  }
  if (fd == -1) return nil;
  return [[self alloc] initWithFileDescriptor:fd
                                closeOnDealloc:YES];
}

- (void)logMessage:(NSString *)msg level:(GTMLoggerLevel)level {
  @synchronized(self) {
    // Closed pipes should not generate exceptions in our caller. Catch here
    // as well [GTMLogger logInternalFunc:...] so that an exception in this
    // writer does not prevent other writers from having a chance.
    @try {
      NSString *line = [NSString stringWithFormat:@"%@\n", msg];
      [self writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (id e) {
      // Ignored
    }
  }
}

@end  // GTMFileHandleLogWriter


@implementation NSArray (GTMArrayCompositeLogWriter)

- (void)logMessage:(NSString *)msg level:(GTMLoggerLevel)level {
  @synchronized(self) {
    id<GTMLogWriter> child = nil;
    for (child in self) {
      if ([child conformsToProtocol:@protocol(GTMLogWriter)])
        [child logMessage:msg level:level];
    }
  }
}

@end  // GTMArrayCompositeLogWriter


@implementation GTMLogger (GTMLoggerLogWriter)

- (void)logMessage:(NSString *)msg level:(GTMLoggerLevel)level {
  switch (level) {
    case kGTMLoggerLevelDebug:
      [self logDebug:@"%@", msg];
      break;
    case kGTMLoggerLevelInfo:
      [self logInfo:@"%@", msg];
      break;
    case kGTMLoggerLevelError:
      [self logError:@"%@", msg];
      break;
    case kGTMLoggerLevelAssert:
      [self logAssert:@"%@", msg];
      break;
    default:
      // Ignore the message.
      break;
  }
}

@end  // GTMLoggerLogWriter


@implementation GTMLogBasicFormatter

- (NSString *)prettyNameForFunc:(NSString *)func {
  NSString *name = [func stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *function = @"(unknown)";
  if ([name length]) {
    if (// Objective C __func__ and __PRETTY_FUNCTION__
        [name hasPrefix:@"-["] || [name hasPrefix:@"+["] ||
        // C++ __PRETTY_FUNCTION__ and other preadorned formats
        [name hasSuffix:@")"]) {
      function = name;
    } else {
      // Assume C99 __func__
      function = [NSString stringWithFormat:@"%@()", name];
    }
  }
  return function;
}

- (NSString *)stringForFunc:(NSString *)func
                 withFormat:(NSString *)fmt
                     valist:(va_list)args
                      level:(GTMLoggerLevel)level {
  // Performance note: We may want to do a quick check here to see if |fmt|
  // contains a '%', and if not, simply return 'fmt'.
  if (!(fmt && args)) return nil;
  return [[NSString alloc] initWithFormat:fmt arguments:args];
}

@end  // GTMLogBasicFormatter


@implementation GTMLogStandardFormatter

- (instancetype)init {
  if ((self = [super init])) {
    dateFormatter_ = [[NSDateFormatter alloc] init];
    [dateFormatter_ setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    pname_ = [[[NSProcessInfo processInfo] processName] copy];
    pid_ = [[NSProcessInfo processInfo] processIdentifier];
    if (!(dateFormatter_ && pname_)) {
      return nil;
    }
  }
  return self;
}

- (NSString *)stringForFunc:(NSString *)func
                 withFormat:(NSString *)fmt
                     valist:(va_list)args
                      level:(GTMLoggerLevel)level {
  NSString *tstamp = nil;
  @synchronized (dateFormatter_) {
    tstamp = [dateFormatter_ stringFromDate:[NSDate date]];
  }
  return [NSString stringWithFormat:@"%@ %@[%d/%p] [lvl=%d] %@ %@",
           tstamp, pname_, pid_, pthread_self(),
           level, [self prettyNameForFunc:func],
           // |super| has guard for nil |fmt| and |args|
           [super stringForFunc:func withFormat:fmt valist:args level:level]];
}

@end  // GTMLogStandardFormatter

static NSString *const kVerboseLoggingKey = @"GTMVerboseLogging";

// Check the environment and the user preferences for the GTMVerboseLogging key
// to see if verbose logging has been enabled. The environment variable will
// override the defaults setting, so check the environment first.
// COV_NF_START
static BOOL IsVerboseLoggingEnabled(NSUserDefaults *userDefaults) {
  NSString *value = [[[NSProcessInfo processInfo] environment]
                        objectForKey:kVerboseLoggingKey];
  if (value) {
    // Emulate [NSString boolValue] for pre-10.5
    value = [value stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([[value uppercaseString] hasPrefix:@"Y"] ||
        [[value uppercaseString] hasPrefix:@"T"] ||
        [value intValue]) {
      return YES;
    } else {
      return NO;
    }
  }
  return [userDefaults boolForKey:kVerboseLoggingKey];
}
// COV_NF_END

@interface GTMLogLevelFilter ()

@property (atomic) BOOL verboseLoggingEnabled;

@end

@implementation GTMLogLevelFilter

- (instancetype)init {
  self = [super init];
  if (self) {
    self.verboseLoggingEnabled = IsVerboseLoggingEnabled(userDefaults_);
  }

  return self;
}

- (void)dealloc {
  _GTMDevAssert(!userDefaults_,
                @"The user defaults instance is still retained, which means "
                @"there was a missing `willDetachFromLogger` call. It is "
                @"important to balance the `didAttachToLogger` call with a "
                @"`willDetachFromLogger` call because those methods "
                @"register/unregister the `GTMLogLevelFilter` instance as an "
                @"observer of the user defaults instance.");
}

// In DEBUG builds, log everything. If we're not in a debug build we'll assume
// that we're in a Release build.
- (BOOL)filterAllowsMessage:(NSString *)msg level:(GTMLoggerLevel)level {
#if defined(DEBUG) && DEBUG
  return YES;
#endif

  BOOL allow = YES;

  switch (level) {
    case kGTMLoggerLevelDebug:
      allow = NO;
      break;
    case kGTMLoggerLevelInfo:
      allow = self.verboseLoggingEnabled;
      break;
    case kGTMLoggerLevelError:
      allow = YES;
      break;
    case kGTMLoggerLevelAssert:
      allow = YES;
      break;
    default:
      allow = YES;
      break;
  }

  return allow;
}

- (void)didAttachToLogger {
  [self startObservingUserDefaultsIfNeeded];
}

- (void)willDetachFromLogger {
  // Unregistration needs to happen earlier than dealloc to avoid the following
  // race condition:
  // 1. [Thread A] A GTMLogLevelFilter instance is initialized. It starts to
  //               observe NSUserDefaults.
  // 2. [Thread A] The instance is released and is starting to be deallocated.
  //               Its dealloc has not been executed yet, so the instance is
  //               still registered as an observer.
  // 3. [Thread B] A user defaults value is modified. NSUserDefaults prepares to
  //               notify observers by retaining its observers. The
  //               GTMLogLevelFilter instance is successfully “retained” even
  //               though it is being deallocated.
  // 4. [Thread A] The instance finishes deallocation.
  // 5. [Thread B] NSUserDefaults finishes notifying observers by releasing the
  //               observers it previously retained. This causes a crash because
  //               the GTMLogLevelFilter instance has already been deallocated.
  [self stopObservingUserDefaultsIfNeeded];
}

- (void)startObservingUserDefaultsIfNeeded {
  if (userDefaults_) {
    return;
  }

  // Keep a reference to standardUserDefaults, avoiding a crash if client code calls
  // "NSUserDefaults resetStandardUserDefaults" which releases it from memory. We are still
  // notified of changes through our instance. Note: resetStandardUserDefaults does not actually
  // clear settings:
  // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/index.html#//apple_ref/occ/clm/NSUserDefaults/resetStandardUserDefaults
  // and so should only be called in test code if necessary.
  userDefaults_ = [NSUserDefaults standardUserDefaults];
  [userDefaults_ addObserver:self
                  forKeyPath:kVerboseLoggingKey
                     options:NSKeyValueObservingOptionInitial
                     context:nil];
}

- (void)stopObservingUserDefaultsIfNeeded {
  if (!userDefaults_) {
    return;
  }

  [userDefaults_ removeObserver:self forKeyPath:kVerboseLoggingKey];
  userDefaults_ = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if([keyPath isEqual:kVerboseLoggingKey]) {
    self.verboseLoggingEnabled = IsVerboseLoggingEnabled(userDefaults_);
  }
}

@end  // GTMLogLevelFilter


@implementation GTMLogNoFilter

- (BOOL)filterAllowsMessage:(NSString *)msg level:(GTMLoggerLevel)level {
  return YES;  // Allow everything through
}

@end  // GTMLogNoFilter


@implementation GTMLogAllowedLevelFilter

// Private designated initializer
- (instancetype)initWithAllowedLevels:(NSIndexSet *)levels {
  self = [super init];
  if (self != nil) {
    allowedLevels_ = levels;
    // Cap min/max level
    if (!allowedLevels_ ||
        // NSIndexSet is unsigned so only check the high bound, but need to
        // check both first and last index because NSIndexSet appears to allow
        // wraparound.
        ([allowedLevels_ firstIndex] > kGTMLoggerLevelAssert) ||
        ([allowedLevels_ lastIndex] > kGTMLoggerLevelAssert)) {
      return nil;
    }
  }
  return self;
}

- (instancetype)init {
  // Allow all levels in default init
  return [self initWithAllowedLevels:[NSIndexSet indexSetWithIndexesInRange:
             NSMakeRange(kGTMLoggerLevelUnknown,
                 (kGTMLoggerLevelAssert - kGTMLoggerLevelUnknown + 1))]];
}

- (BOOL)filterAllowsMessage:(NSString *)msg level:(GTMLoggerLevel)level {
  return [allowedLevels_ containsIndex:level];
}

@end  // GTMLogAllowedLevelFilter


@implementation GTMLogMininumLevelFilter

- (instancetype)initWithMinimumLevel:(GTMLoggerLevel)level {
  return [super initWithAllowedLevels:[NSIndexSet indexSetWithIndexesInRange:
             NSMakeRange(level,
                         (kGTMLoggerLevelAssert - level + 1))]];
}

@end  // GTMLogMininumLevelFilter


@implementation GTMLogMaximumLevelFilter

- (instancetype)initWithMaximumLevel:(GTMLoggerLevel)level {
  return [super initWithAllowedLevels:[NSIndexSet indexSetWithIndexesInRange:
             NSMakeRange(kGTMLoggerLevelUnknown, level + 1)]];
}

@end  // GTMLogMaximumLevelFilter

#if !defined(__clang__) && (__GNUC__*10+__GNUC_MINOR__ >= 42)
// See comment at top of file.
#pragma GCC diagnostic error "-Wmissing-format-attribute"
#endif  // !__clang__
