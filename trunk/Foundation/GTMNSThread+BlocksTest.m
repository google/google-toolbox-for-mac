//
//  GTMNSThread+BlocksTest.m
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

#import <pthread.h>
#import "GTMSenTestCase.h"
#import "GTMNSThread+Blocks.h"

#if GTM_IPHONE_SDK || (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)

#import "GTMFoundationUnitTestingUtilities.h"

@interface GTMNSThread_BlocksTest : GTMTestCase {
 @private
  GTMSimpleWorkerThread *workerThread_;
}
@end

@implementation GTMNSThread_BlocksTest

- (void)setUp {
  workerThread_ = [[GTMSimpleWorkerThread alloc] init];
  [workerThread_ start];
}

- (void)tearDown {
  [workerThread_ stop];
  [workerThread_ release];
}

- (void)testPerformBlockOnCurrentThread {
  NSThread *currentThread = [NSThread currentThread];

  GTMUnitTestingBooleanRunLoopContext *context =
      [GTMUnitTestingBooleanRunLoopContext context];
  __block NSThread *runThread = nil;

  // Straight block runs right away (no runloop spin)
  runThread = nil;
  [context setShouldStop:NO];
  [currentThread gtm_performBlock:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertEqualObjects(runThread, currentThread, nil);
  STAssertTrue([context shouldStop], nil);

  // Block with waiting runs immediately as well.
  runThread = nil;
  [context setShouldStop:NO];
  [currentThread gtm_performWaitingUntilDone:YES block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertEqualObjects(runThread, currentThread, nil);
  STAssertTrue([context shouldStop], nil);

  // Block without waiting requires a runloop spin.
  runThread = nil;
  [context setShouldStop:NO];
  [currentThread gtm_performWaitingUntilDone:NO block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertTrue([[NSRunLoop currentRunLoop]
                    gtm_runUpToSixtySecondsWithContext:context], nil);
  STAssertEqualObjects(runThread, currentThread, nil);
  STAssertTrue([context shouldStop], nil);
}

- (void)testPerformBlockInBackground {
  GTMUnitTestingBooleanRunLoopContext *context =
      [GTMUnitTestingBooleanRunLoopContext context];
  __block NSThread *runThread = nil;
  [NSThread gtm_performBlockInBackground:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertTrue([[NSRunLoop currentRunLoop]
                    gtm_runUpToSixtySecondsWithContext:context], nil);
  STAssertNotNil(runThread, nil);
  STAssertNotEqualObjects(runThread, [NSThread currentThread], nil);
}

- (void)testWorkerThreadBasics {
  // Unstarted worker isn't running.
  GTMSimpleWorkerThread *worker = [[GTMSimpleWorkerThread alloc] init];
  STAssertFalse([worker isExecuting], nil);
  STAssertFalse([worker isFinished], nil);

  // Unstarted worker can be stopped without error.
  [worker stop];
  STAssertFalse([worker isExecuting], nil);
  STAssertTrue([worker isFinished], nil);

  // And can be stopped again
  [worker stop];
  STAssertFalse([worker isExecuting], nil);
  STAssertTrue([worker isFinished], nil);

  // A thread we start can be stopped with correct state.
  worker = [[GTMSimpleWorkerThread alloc] init];
  STAssertFalse([worker isExecuting], nil);
  STAssertFalse([worker isFinished], nil);
  [worker start];
  STAssertTrue([worker isExecuting], nil);
  STAssertFalse([worker isFinished], nil);
  [worker stop];
  STAssertFalse([worker isExecuting], nil);
  STAssertTrue([worker isFinished], nil);

  // A cancel is also honored
  worker = [[GTMSimpleWorkerThread alloc] init];
  STAssertFalse([worker isExecuting], nil);
  STAssertFalse([worker isFinished], nil);
  [worker start];
  STAssertTrue([worker isExecuting], nil);
  STAssertFalse([worker isFinished], nil);
  [worker cancel];
  // And after some time we're done. We're generous here, this needs to
  // exceed the worker thread's runloop timeout.
  sleep(5);
  STAssertFalse([worker isExecuting], nil);
  STAssertTrue([worker isFinished], nil);
}

- (void)testWorkerThreadStopTiming {
  // Throw a sleep and make sure that we stop as soon as we can.
  NSDate *start = [NSDate date];
  NSConditionLock *threadLock = [[[NSConditionLock alloc] initWithCondition:0]
                                    autorelease];
  [workerThread_ gtm_performBlock:^{
    [threadLock lock];
    [threadLock unlockWithCondition:1];
    sleep(10);
  }];
  [threadLock lockWhenCondition:1];
  [threadLock unlock];
  [workerThread_ stop];
  STAssertFalse([workerThread_ isExecuting], nil);
  STAssertTrue([workerThread_ isFinished], nil);
  STAssertEqualsWithAccuracy(-[start timeIntervalSinceNow], 10.0, 2.0, nil);
}

- (void)testPerformBlockOnWorkerThread {
  GTMUnitTestingBooleanRunLoopContext *context =
      [GTMUnitTestingBooleanRunLoopContext context];
  __block NSThread *runThread = nil;

  // Runs on the other thread
  runThread = nil;
  [context setShouldStop:NO];
  [workerThread_ gtm_performBlock:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertTrue([[NSRunLoop currentRunLoop]
                    gtm_runUpToSixtySecondsWithContext:context], nil);
  STAssertNotNil(runThread, nil);
  STAssertEqualObjects(runThread, workerThread_, nil);

  // Other thread no wait.
  runThread = nil;
  [context setShouldStop:NO];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertTrue([[NSRunLoop currentRunLoop]
                    gtm_runUpToSixtySecondsWithContext:context], nil);
  STAssertNotNil(runThread, nil);
  STAssertEqualObjects(runThread, workerThread_, nil);

  // Waiting requires no runloop spin
  runThread = nil;
  [context setShouldStop:NO];
  [workerThread_ gtm_performWaitingUntilDone:YES block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  STAssertTrue([context shouldStop], nil);
  STAssertNotNil(runThread, nil);
  STAssertEqualObjects(runThread, workerThread_, nil);
}

- (void)testExitingBlockIsExecuting {
  NSConditionLock *threadLock = [[[NSConditionLock alloc] initWithCondition:0]
                                    autorelease];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    [threadLock lock];
    [threadLock unlockWithCondition:1];
    pthread_exit(NULL);
  }];
  [threadLock lockWhenCondition:1];
  [threadLock unlock];
  // Give the pthread_exit() a bit of time
  sleep(5);
  // Did we notice the thread died? Does [... isExecuting] clean up?
  STAssertFalse([workerThread_ isExecuting], nil);
  STAssertTrue([workerThread_ isFinished], nil);
}

- (void)testExitingBlockCancel {
  NSConditionLock *threadLock = [[[NSConditionLock alloc] initWithCondition:0]
                                    autorelease];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    [threadLock lock];
    [threadLock unlockWithCondition:1];
    pthread_exit(NULL);
  }];
  [threadLock lockWhenCondition:1];
  [threadLock unlock];
  // Give the pthread_exit() a bit of time
  sleep(5);
  // Cancel/stop the thread
  [workerThread_ stop];
  // Did we notice the thread died? Did we clean up?
  STAssertFalse([workerThread_ isExecuting], nil);
  STAssertTrue([workerThread_ isFinished], nil);
}

- (void)testStopFromThread {
  NSConditionLock *threadLock = [[[NSConditionLock alloc] initWithCondition:0]
                                    autorelease];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    [threadLock lock];
    [workerThread_ stop];  // Shold not block.
    [threadLock unlockWithCondition:1];
  }];
  // Block should complete before the stop occurs.
  [threadLock lockWhenCondition:1];
  [threadLock unlock];
  // Still need to give the thread a moment to not be executing
  sleep(5);
  STAssertFalse([workerThread_ isExecuting], nil);
  STAssertTrue([workerThread_ isFinished], nil);
}

- (void)testPThreadName {
  NSString *testName = @"InigoMontoya";
  [workerThread_ setName:testName];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    STAssertEqualObjects([workerThread_ name], testName, nil);
    char threadName[100];
    pthread_getname_np(pthread_self(), threadName, 100);
    STAssertEqualObjects([NSString stringWithUTF8String:threadName],
                         testName, nil);
  }];
}

@end

#endif  // GTM_IPHONE_SDK || (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)
