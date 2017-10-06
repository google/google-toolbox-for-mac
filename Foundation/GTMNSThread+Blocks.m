//
//  GTMNSThread+Blocks.m
//
//  Copyright 2012 Google Inc.
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
//  License for the specific language governing permissions and limitations
//  under the License.
//

#import "GTMNSThread+Blocks.h"

#import <pthread.h>
#import <dlfcn.h>

#if NS_BLOCKS_AVAILABLE

@implementation NSThread (GTMBlocksAdditions)

+ (void)gtm_runBlockOnCurrentThread:(void (^)(void))block {
  block();
}

- (void)gtm_performBlock:(void (^)(void))block {
  if ([[NSThread currentThread] isEqual:self]) {
    block();
  } else {
    [self gtm_performWaitingUntilDone:NO block:block];
  }
}

- (void)gtm_performWaitingUntilDone:(BOOL)waitDone block:(void (^)(void))block {
  [NSThread performSelector:@selector(gtm_runBlockOnCurrentThread:)
                   onThread:self
                 withObject:[[block copy] autorelease]
              waitUntilDone:waitDone];
}

+ (void)gtm_performBlockInBackground:(void (^)(void))block {
  [NSThread performSelectorInBackground:@selector(gtm_runBlockOnCurrentThread:)
                             withObject:[[block copy] autorelease]];
}

@end

#endif  // NS_BLOCKS_AVAILABLE

enum {
  kGTMSimpleThreadInitialized = 0,
  kGTMSimpleThreadStarting,
  kGTMSimpleThreadRunning,
  kGTMSimpleThreadCancel,
  kGTMSimpleThreadFinished,
};

@implementation GTMSimpleWorkerThread

- (id)init {
  if ((self = [super init])) {
    runLock_ =
        [[NSConditionLock alloc] initWithCondition:kGTMSimpleThreadInitialized];
  }
  return self;
}

- (void)dealloc {
  if ([self isExecuting]) {
    [self stop];
  }
  [runLock_ release];
  [super dealloc];
}

- (void)setThreadDebuggerName:(NSString *)name {
  if ([name length]) {
    pthread_setname_np([name UTF8String]);
  } else {
    pthread_setname_np("");
  }
}

- (void)main {
  [runLock_ lock];
  if ([runLock_ condition] != kGTMSimpleThreadStarting) {
    // Don't start, we're already cancelled or we've been started twice.
    [runLock_ unlock];
    return;
  }

  // Give ourself an autopool
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  // Expose the current runloop so other threads can stop (but see caveat
  // below).
  NSRunLoop *loop = [NSRunLoop currentRunLoop];
  runLoop_ = [loop getCFRunLoop];
  if (runLoop_) CFRetain(runLoop_);  // NULL check is pure paranoia.

  // Add a port to the runloop so that it stays alive. Without a port attached
  // to it, a runloop will immediately return when you call run on it.
  [loop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];

  // Name ourself
  [self setThreadDebuggerName:[self name]];

  // We're officially running.
  [runLock_ unlockWithCondition:kGTMSimpleThreadRunning];

  while (![self isCancelled] &&
         [runLock_ tryLockWhenCondition:kGTMSimpleThreadRunning]) {
    [runLock_ unlock];
    // We can't control nesting of runloops, so we spin with a short timeout. If
    // another thread cancels us the CFRunloopStop() we might get it right away,
    // if there is no nesting, otherwise our timeout will still get us to exit
    // in reasonable time.
    [loop runMode:NSDefaultRunLoopMode
         beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    [localPool drain];
    localPool = [[NSAutoreleasePool alloc] init];
  }

  // Exit
  [runLock_ lock];
  [localPool drain];
  if (runLoop_) CFRelease(runLoop_);
  runLoop_ = NULL;
  [runLock_ unlockWithCondition:kGTMSimpleThreadFinished];
}

- (void)start {
  // Before we start the thread we need to make sure its not already running
  // and that the lock is past kGTMSimpleThreadInitialized so an immediate
  // stop is safe.
  [runLock_ lock];
  if ([runLock_ condition] != kGTMSimpleThreadInitialized) {
    [runLock_ unlock];
    return;
  }
  [runLock_ unlockWithCondition:kGTMSimpleThreadStarting];
  [super start];
}

- (void)cancel {
  // NSThread appears to not propagate [... isCancelled] to our thread in
  // this subclass, so we'll let super know and then use our condition lock.
  [super cancel];
  [runLock_ lock];
  switch ([runLock_ condition]) {
    case kGTMSimpleThreadInitialized:
    case kGTMSimpleThreadStarting:
      // Cancelled before we started? Transition straight to finished.
      [runLock_ unlockWithCondition:kGTMSimpleThreadFinished];
      return;
    case kGTMSimpleThreadRunning:
      // If the thread has exited without changing lock state we detect that
      // here. Note this is a direct call to [super isExecuting] to prevent
      // deadlock on |runLock_| in [self isExecuting].
      if (![super isExecuting]) {
        // Thread died in some unanticipated way, clean up on its behalf.
        if (runLoop_) {
          CFRelease(runLoop_);
          runLoop_ = NULL;
        }
        [runLock_ unlockWithCondition:kGTMSimpleThreadFinished];
        return;
      } else {
        // We need to cancel the running loop. We'd like to stop the runloop
        // right now if we can (but see the caveat above about nested runloops).
        if (runLoop_) CFRunLoopStop(runLoop_);
        [runLock_ unlockWithCondition:kGTMSimpleThreadCancel];
        return;
      }
    case kGTMSimpleThreadCancel:
    case kGTMSimpleThreadFinished:
      // Already cancelled or finished. There's an outside chance the thread
      // will have died now (imagine a [... dealloc] that calls pthread_exit())
      // but we'll ignore those cases.
      [runLock_ unlock];
      return;
  }
}

- (void)stop {
  // Cancel does the heavy lifting...
  [self cancel];

  // If we're the current thread then the stop was called from within our
  // own runloop and we need to return control now. [... main] will handle
  // the shutdown on its own.
  if ([[NSThread currentThread] isEqual:self]) return;

  // From all other threads block till we're finished. Note that [... cancel]
  // handles ensuring we will either already be in this state or transition
  // there after thread exit.
  [runLock_ lockWhenCondition:kGTMSimpleThreadFinished];
  [runLock_ unlock];

  // We could still be waiting for thread teardown at this point (lock is in
  // the right state, but thread is not quite torn down), so spin till we say
  // execution is complete (our implementation checks superclass).
  while ([self isExecuting]) {
    usleep(10);
  }
}

- (void)setName:(NSString *)name {
  if ([self isExecuting]) {
    [self performSelector:@selector(setThreadDebuggerName:)
                 onThread:self
               withObject:name
            waitUntilDone:YES];
  }
  [super setName:name];
}

- (BOOL)isCancelled {
  if ([super isCancelled]) return YES;
  BOOL cancelled = NO;
  [runLock_ lock];
  if ([runLock_ condition] == kGTMSimpleThreadCancel) {
    cancelled = YES;
  }
  [runLock_ unlock];
  return cancelled;
}

- (BOOL)isExecuting {
  if ([super isExecuting]) return YES;
  [runLock_ lock];
  switch ([runLock_ condition]) {
    case kGTMSimpleThreadStarting:
      // While starting we may not be executing yet, but we'll pretend we are.
      [runLock_ unlock];
      return YES;
    case kGTMSimpleThreadCancel:
    case kGTMSimpleThreadRunning:
      // Both of these imply we're running, but [super isExecuting] failed,
      // so the thread died for other reasons. Clean up.
      if (runLoop_) {
        CFRelease(runLoop_);
        runLoop_ = NULL;
      }
      [runLock_ unlockWithCondition:kGTMSimpleThreadFinished];
      break;
    default:
      [runLock_ unlock];
      break;
  }
  return NO;
}

- (BOOL)isFinished {
  if ([super isFinished]) return YES;
  if ([self isExecuting]) return NO;  // Will clean up dead thread.
  BOOL finished = NO;
  [runLock_ lock];
  if ([runLock_ condition] == kGTMSimpleThreadFinished) {
    finished = YES;
  }
  [runLock_ unlock];
  return finished;
}

@end
