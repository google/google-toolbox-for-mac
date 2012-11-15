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

// Only available 10.6 and later.
typedef int (*pthread_setname_np_Ptr)(const char*);

#if NS_BLOCKS_AVAILABLE

@implementation NSThread (GTMBlocksAdditions)

+ (void)gtm_runBlockOnCurrentThread:(void (^)())block {
  block();
}

- (void)gtm_performBlock:(void (^)())block {
  if ([[NSThread currentThread] isEqual:self]) {
    block();
  } else {
    [self gtm_performWaitingUntilDone:NO block:block];
  }
}

- (void)gtm_performWaitingUntilDone:(BOOL)waitDone block:(void (^)())block {
  [NSThread performSelector:@selector(gtm_runBlockOnCurrentThread:)
                   onThread:self
                 withObject:[[block copy] autorelease]
              waitUntilDone:waitDone];
}

+ (void)gtm_performBlockInBackground:(void (^)())block {
  [NSThread performSelectorInBackground:@selector(gtm_runBlockOnCurrentThread:)
                             withObject:[[block copy] autorelease]];
}

@end

#endif  // NS_BLOCKS_AVAILABLE

#if GTM_IPHONE_SDK || (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)

@implementation GTMSimpleWorkerThread

- (void)setThreadDebuggerName:(NSString *)name {
  // [NSThread setName:] doesn't actually set the name in such a way that the
  // debugger can see it. So we handle it here instead.
  // pthread_setname_np only available 10.6 and later, look up dynamically.
  pthread_setname_np_Ptr setName = dlsym(RTLD_DEFAULT, "pthread_setname_np");
  if (!setName) return;
  setName([name UTF8String]);
}

- (void)main {
  [self setThreadDebuggerName:[self name]];

  // Add a port to the runloop so that it stays alive. Without a port attached
  // to it, a runloop will immediately return when you call run on it.
  NSPort *tempPort = [NSPort port];
  NSRunLoop *loop = [NSRunLoop currentRunLoop];
  [loop addPort:tempPort forMode:NSDefaultRunLoopMode];

  // Run the loop using CFRunLoopRun because [NSRunLoop run] will sometimes nest
  // runloops making it impossible to stop.
  runLoop_ = [loop getCFRunLoop];
  CFRunLoopRun();
}

- (void)stop {
  CFRunLoopStop(runLoop_);
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

@end

#endif  // GTM_IPHONE_SDK || (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)
