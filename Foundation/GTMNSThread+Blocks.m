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

@implementation GTMSimpleWorkerThread {
  NSLock *sourceLock_;
  CFRunLoopSourceRef source_;  // Protected by sourceLock_
  CFRunLoopRef cfRunLoop_;
}

static void RunLoopContextEmptyFunc(void *info) {
  // Empty because the source is used solely for signalling.
  // The documentation for CFRunLoopSourceContext does not
  // make it clear if you can have a null perform method.
}

- (void)main {
  NSRunLoop *nsRunLoop = [NSRunLoop currentRunLoop];
  {  // Braces are just to denote what is protected by sourceLock_
    [sourceLock_ lock];
    cfRunLoop_ = [nsRunLoop getCFRunLoop];
    CFRetain(cfRunLoop_);
    CFRunLoopSourceContext context = {0};
    context.perform = RunLoopContextEmptyFunc;
    source_ = CFRunLoopSourceCreate(NULL, 0, &context);
    CFRunLoopAddSource(cfRunLoop_, source_, kCFRunLoopCommonModes);
    [sourceLock_ unlock];
  }
  while (true) {
    BOOL cancelled = [self isCancelled];
    if (cancelled) {
      break;
    }
    BOOL ranLoop = [nsRunLoop runMode:NSDefaultRunLoopMode
                           beforeDate:[NSDate distantFuture]];
    if (!ranLoop) {
      break;
    }
  }
}

- (void)dealloc {
  if (cfRunLoop_) {
    CFRelease(cfRunLoop_);
  }
  if (source_) {
    CFRelease(source_);
  }
  [super dealloc];
}

- (void)start {
  // Protect lock in case we are "started" twice in different threads.
  // NSThread has no documentation regarding the safety of this, so
  // making safe by default.
  @synchronized (self) {
    if (sourceLock_) {
      return;
    }
    sourceLock_ = [[NSLock alloc] init];
  }
  [super start];
}

- (void)cancel {
  [super cancel];
  {  // Braces are just to denote what is protected by sourceLock_
    [sourceLock_ lock];
    if (source_) {
      CFRunLoopSourceSignal(source_);
      CFRunLoopWakeUp(cfRunLoop_);
    }
    [sourceLock_ unlock];
  }
}

@end
