//
//  GTMScriptRunner.m
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

#import "GTMScriptRunner.h"
#import "GTMDefines.h"

#include <sys/ioctl.h>

static BOOL LaunchNSTaskCatchingExceptions(NSTask *task);

@interface GTMScriptRunner (PrivateMethods)
- (NSTask *)interpreterTaskWithAdditionalArgs:(NSArray *)args;
@end

@implementation GTMScriptRunner

+ (GTMScriptRunner *)runner {
  return [[[self alloc] init] autorelease];
}

+ (GTMScriptRunner *)runnerWithBash {
  return [self runnerWithInterpreter:@"/bin/bash"];
}

+ (GTMScriptRunner *)runnerWithPerl {
  return [self runnerWithInterpreter:@"/usr/bin/perl"];  
}

+ (GTMScriptRunner *)runnerWithPython {
  return [self runnerWithInterpreter:@"/usr/bin/python"]; 
}

+ (GTMScriptRunner *)runnerWithInterpreter:(NSString *)interp {
  return [self runnerWithInterpreter:interp withArgs:nil];
}

+ (GTMScriptRunner *)runnerWithInterpreter:(NSString *)interp withArgs:(NSArray *)args {
  return [[[self alloc] initWithInterpreter:interp withArgs:args] autorelease];
}

- (id)init {
  return [self initWithInterpreter:nil];
}

- (id)initWithInterpreter:(NSString *)interp {
  return [self initWithInterpreter:interp withArgs:nil];
}

- (id)initWithInterpreter:(NSString *)interp withArgs:(NSArray *)args {
  if ((self = [super init])) {
    trimsWhitespace_ = YES;
    interpreter_ = [interp copy];
    interpreterArgs_ = [args retain];
    if (!interpreter_) {
      interpreter_ = @"/bin/sh";
    }
  }
  return self;
}

- (void)dealloc {
  [environment_ release];
  [interpreter_ release];
  [interpreterArgs_ release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@<%p>{ interpreter = '%@', args = %@, environment = %@ }",
          [self class], self, interpreter_, interpreterArgs_, environment_];
}

- (NSString *)run:(NSString *)cmds {
  return [self run:cmds standardError:nil];
}

- (NSString *)run:(NSString *)cmds standardError:(NSString **)err {
  if (!cmds) return nil;
  
  NSTask *task = [self interpreterTaskWithAdditionalArgs:nil];
  NSFileHandle *toTask = [[task standardInput] fileHandleForWriting];
  NSFileHandle *fromTask = [[task standardOutput] fileHandleForReading];
  NSFileHandle *errTask = [[task standardError] fileHandleForReading];

  if (!LaunchNSTaskCatchingExceptions(task)) {
    return nil;
  }
  
  [toTask writeData:[cmds dataUsingEncoding:NSUTF8StringEncoding]];
  [toTask closeFile];

  // Must keep both file handle buffers empty to avoid the deadlock described in
  // http://code.google.com/p/google-toolbox-for-mac/issues/detail?id=25
  NSMutableString *mutableOutString = [NSMutableString string];
  NSMutableString *mutableErrString = [NSMutableString string];
  while (true) {
    // availableByteCountNonBlocking must be called on both fromTask and errTask
    // each time through the loop.
    unsigned int bytesFromTask = [self availableByteCountNonBlocking:fromTask];
    unsigned int bytesErrTask = [self availableByteCountNonBlocking:errTask];
    if (![task isRunning] && (bytesFromTask == 0) && (bytesErrTask == 0)) {
      break;
    }
    if (bytesFromTask > 0) {
      NSData *outData = [fromTask availableData];
      NSString *dataString =
          [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
      [mutableOutString appendString:dataString];
      [dataString release];
    }
    if (bytesErrTask > 0 && err) {
      NSData *errData = [errTask availableData];
      NSString *dataString =
          [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
      [mutableErrString appendString:dataString];
      [dataString release];
    }
  }
  
  [task terminate];

  NSString *outString = mutableOutString;
  NSString *errString = mutableErrString;

  if (trimsWhitespace_) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    outString = [outString stringByTrimmingCharactersInSet:set];
    if (err) {
      errString = [errString stringByTrimmingCharactersInSet:set];
    }
  }
  
  // let folks test for nil instead of @""
  if ([outString length] < 1) {
    outString = nil;
  }

  // Handle returning standard error if |err| is not nil
  if (err) {
    // let folks test for nil instead of @""
    if ([errString length] < 1) {
      *err = nil;
    } else {
      *err = errString;
    }
  }

  return outString;
}

- (unsigned int)availableByteCountNonBlocking:(NSFileHandle *)file {
  int fd = [file fileDescriptor];
  int numBytes;
  if (ioctl(fd, FIONREAD, (char *) &numBytes) == -1) {
    [NSException raise:NSFileHandleOperationException
                format:@"ioctl() error %d", errno];
  }
  return numBytes;
}

- (NSString *)runScript:(NSString *)path {
  return [self runScript:path withArgs:nil];
}

- (NSString *)runScript:(NSString *)path withArgs:(NSArray *)args {
  return [self runScript:path withArgs:args standardError:nil];
}

- (NSString *)runScript:(NSString *)path withArgs:(NSArray *)args standardError:(NSString **)err {
  if (!path) return nil;
  
  NSArray *scriptPlusArgs = [[NSArray arrayWithObject:path] arrayByAddingObjectsFromArray:args];
  NSTask *task = [self interpreterTaskWithAdditionalArgs:scriptPlusArgs];
  NSFileHandle *fromTask = [[task standardOutput] fileHandleForReading];
  
  if (!LaunchNSTaskCatchingExceptions(task)) {
    return nil;
  }

  NSData *outData = [fromTask readDataToEndOfFile];
  NSString *output = [[[NSString alloc] initWithData:outData
                                            encoding:NSUTF8StringEncoding] autorelease];
  
  // Handle returning standard error if |err| is not nil
  if (err) {
    NSFileHandle *stderror = [[task standardError] fileHandleForReading];
    NSData *errData = [stderror readDataToEndOfFile];
    *err = [[[NSString alloc] initWithData:errData
                                  encoding:NSUTF8StringEncoding] autorelease];
    if (trimsWhitespace_) {
      *err = [*err stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    // let folks test for nil instead of @""
    if ([*err length] < 1) {
      *err = nil;
    }
  }
  
  [task terminate];
  
  if (trimsWhitespace_) {
    output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  }
  
  // let folks test for nil instead of @""
  if ([output length] < 1) {
    output = nil;
  }
  
  return output;
}

- (NSDictionary *)environment {
  return environment_;
}

- (void)setEnvironment:(NSDictionary *)newEnv {
  [environment_ autorelease];
  environment_ = [newEnv retain];
}

- (BOOL)trimsWhitespace {
  return trimsWhitespace_;
}

- (void)setTrimsWhitespace:(BOOL)trim {
  trimsWhitespace_ = trim;
}

@end


@implementation GTMScriptRunner (PrivateMethods)

- (NSTask *)interpreterTaskWithAdditionalArgs:(NSArray *)args {
  NSTask *task = [[[NSTask alloc] init] autorelease];
  [task setLaunchPath:interpreter_];
  [task setStandardInput:[NSPipe pipe]];
  [task setStandardOutput:[NSPipe pipe]];
  [task setStandardError:[NSPipe pipe]];
  
  // If |environment_| is nil, then use an empty dictionary, otherwise use
  // environment_ exactly.
  [task setEnvironment:(environment_
                        ? environment_
                        : [NSDictionary dictionary])];
  
  // Build args to interpreter.  The format is:
  //   interp [args-to-interp] [script-name [args-to-script]]
  NSArray *allArgs = nil;
  if (interpreterArgs_) {
    allArgs = interpreterArgs_;
  }
  if (args) {
    allArgs = allArgs ? [allArgs arrayByAddingObjectsFromArray:args] : args;
  }
  if (allArgs){
    [task setArguments:allArgs];
  }
  
  return task;
}

@end

static BOOL LaunchNSTaskCatchingExceptions(NSTask *task) {
  BOOL isOK = YES;
  @try {
    [task launch];
  } @catch (id ex) {
    isOK = NO;
    _GTMDevLog(@"Failed to launch interpreter '%@' due to: %@",
               [task launchPath], ex);
  }
  return isOK;
}
