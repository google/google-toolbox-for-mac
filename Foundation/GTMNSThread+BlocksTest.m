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
  XCTAssertEqualObjects(runThread, currentThread);
  XCTAssertTrue([context shouldStop]);

  // Block with waiting runs immediately as well.
  runThread = nil;
  [context setShouldStop:NO];
  [currentThread gtm_performWaitingUntilDone:YES block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  XCTAssertEqualObjects(runThread, currentThread);
  XCTAssertTrue([context shouldStop]);

  // Block without waiting requires a runloop spin.
  runThread = nil;
  [context setShouldStop:NO];
  [currentThread gtm_performWaitingUntilDone:NO block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  XCTAssertTrue([[NSRunLoop currentRunLoop]
                 gtm_runUpToSixtySecondsWithContext:context]);
  XCTAssertEqualObjects(runThread, currentThread);
  XCTAssertTrue([context shouldStop]);
}

- (void)testPerformBlockInBackground {
  GTMUnitTestingBooleanRunLoopContext *context =
      [GTMUnitTestingBooleanRunLoopContext context];
  __block NSThread *runThread = nil;
  [NSThread gtm_performBlockInBackground:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  XCTAssertTrue([[NSRunLoop currentRunLoop]
                 gtm_runUpToSixtySecondsWithContext:context]);
  XCTAssertNotNil(runThread);
  XCTAssertNotEqualObjects(runThread, [NSThread currentThread]);
}

- (void)testWorkerThreadBasics {
  // Unstarted worker isn't running.
  GTMSimpleWorkerThread *worker = [[GTMSimpleWorkerThread alloc] init];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertFalse([worker isFinished]);

  // Unstarted worker can be stopped without error.
  [worker stop];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertTrue([worker isFinished]);

  // And can be stopped again
  [worker stop];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertTrue([worker isFinished]);

  // A thread we start can be stopped with correct state.
  worker = [[GTMSimpleWorkerThread alloc] init];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertFalse([worker isFinished]);
  [worker start];
  XCTAssertTrue([worker isExecuting]);
  XCTAssertFalse([worker isFinished]);
  [worker stop];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertTrue([worker isFinished]);

  // A cancel is also honored
  worker = [[GTMSimpleWorkerThread alloc] init];
  XCTAssertFalse([worker isExecuting]);
  XCTAssertFalse([worker isFinished]);
  [worker start];
  XCTAssertTrue([worker isExecuting]);
  XCTAssertFalse([worker isFinished]);
  [worker cancel];
  // And after some time we're done. We're generous here, this needs to
  // exceed the worker thread's runloop timeout.
  sleep(5);
  XCTAssertFalse([worker isExecuting]);
  XCTAssertTrue([worker isFinished]);
}

- (void)testWorkerThreadStopTiming {
  // Throw a sleep and make sure that we stop as soon as we can.
  NSDate *start = [NSDate date];
  NSConditionLock *threadLock = [[[NSConditionLock alloc] initWithCondition:0]
                                    autorelease];
  [workerThread_ gtm_performBlock:^{
    [threadLock lock];
    [threadLock unlockWithCondition:1];
    [NSThread sleepForTimeInterval:.25];
  }];
  [threadLock lockWhenCondition:1];
  [threadLock unlock];
  [workerThread_ stop];
  XCTAssertFalse([workerThread_ isExecuting]);
  XCTAssertTrue([workerThread_ isFinished]);
  XCTAssertEqualWithAccuracy(-[start timeIntervalSinceNow], 0.25, 0.25);
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
  XCTAssertTrue([[NSRunLoop currentRunLoop]
                 gtm_runUpToSixtySecondsWithContext:context]);
  XCTAssertNotNil(runThread);
  XCTAssertEqualObjects(runThread, workerThread_);

  // Other thread no wait.
  runThread = nil;
  [context setShouldStop:NO];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  XCTAssertTrue([[NSRunLoop currentRunLoop]
                 gtm_runUpToSixtySecondsWithContext:context]);
  XCTAssertNotNil(runThread);
  XCTAssertEqualObjects(runThread, workerThread_);

  // Waiting requires no runloop spin
  runThread = nil;
  [context setShouldStop:NO];
  [workerThread_ gtm_performWaitingUntilDone:YES block:^{
    runThread = [NSThread currentThread];
    [context setShouldStop:YES];
  }];
  XCTAssertTrue([context shouldStop]);
  XCTAssertNotNil(runThread);
  XCTAssertEqualObjects(runThread, workerThread_);
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
  [NSThread sleepForTimeInterval:.25];
  // Did we notice the thread died? Does [... isExecuting] clean up?
  XCTAssertFalse([workerThread_ isExecuting]);
  XCTAssertTrue([workerThread_ isFinished]);
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
  [NSThread sleepForTimeInterval:.25];
  // Cancel/stop the thread
  [workerThread_ stop];
  // Did we notice the thread died? Did we clean up?
  XCTAssertFalse([workerThread_ isExecuting]);
  XCTAssertTrue([workerThread_ isFinished]);
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
  sleep(1);
  XCTAssertFalse([workerThread_ isExecuting]);
  XCTAssertTrue([workerThread_ isFinished]);
}

- (void)testPThreadName {
  NSString *testName = @"InigoMontoya";
  [workerThread_ setName:testName];
  [workerThread_ gtm_performWaitingUntilDone:NO block:^{
    XCTAssertEqualObjects([workerThread_ name], testName);
    char threadName[100];
    pthread_getname_np(pthread_self(), threadName, 100);
    XCTAssertEqualObjects([NSString stringWithUTF8String:threadName], testName);
  }];
}

@end
