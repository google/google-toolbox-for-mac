//
//  GTMSignalHandlerTest.m
//
//  Copyright 2008 Google Inc.
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

#import "GTMSenTestCase.h"
#import "GTMSignalHandler.h"
#import "GTMFoundationUnitTestingUtilities.h"

@interface GTMSignalHandlerTest : GTMTestCase
@end

@interface SignalCounter : NSObject<GTMUnitTestingRunLoopContext> {
 @public
  int signalCount_;
  int lastSeenSignal_;
  BOOL shouldStop_;
}
- (int)count;
- (int)lastSeen;
- (void)countSignal:(int)signo;
+ (id)signalCounter;
- (void)resetShouldStop;
@end // SignalCounter

@implementation SignalCounter
+ (id)signalCounter {
  return [[[self alloc] init] autorelease];
}
- (int)count {
  return signalCount_;
}
- (int)lastSeen {
  return lastSeenSignal_;
}
// Count the number of times this signal handler has fired.
- (void)countSignal:(int)signo {
  signalCount_++;
  lastSeenSignal_ = signo;
  shouldStop_ = YES;
}

- (BOOL)shouldStop {
  return shouldStop_;
}

- (void)resetShouldStop {
  shouldStop_ = NO;
}

@end

@implementation GTMSignalHandlerTest
- (void)nomnomnom:(int)blah {
  XCTFail(@"Should never be called!");
}

- (void)testNillage {
  GTMSignalHandler *handler;

  // Just an init should return nil.
  handler = [[[GTMSignalHandler alloc] init] autorelease];
  XCTAssertNil(handler);

  // Zero signal should return nil as well.
  handler = [[[GTMSignalHandler alloc]
              initWithSignal:0
                      target:self
                      action:@selector(nomnomnom:)] autorelease];
  XCTAssertNil(handler);

}

- (void)testSingleHandler {
  SignalCounter *counter = [SignalCounter signalCounter];
  XCTAssertNotNil(counter);

  GTMSignalHandler *handler = [[[GTMSignalHandler alloc]
                                 initWithSignal:SIGWINCH
                                         target:counter
                                         action:@selector(countSignal:)]
                               autorelease];
  XCTAssertNotNil(handler);
  raise(SIGWINCH);

  NSRunLoop *rl = [NSRunLoop currentRunLoop];
  [rl gtm_runUpToSixtySecondsWithContext:counter];

  XCTAssertEqual([counter count], 1);
  XCTAssertEqual([counter lastSeen], SIGWINCH);
  [counter resetShouldStop];

  raise(SIGWINCH);
  [rl gtm_runUpToSixtySecondsWithContext:counter];

  XCTAssertEqual([counter count], 2);
  XCTAssertEqual([counter lastSeen], SIGWINCH);
  [counter resetShouldStop];

  // create a second one to make sure we're seding data where we want
  SignalCounter *counter2 = [SignalCounter signalCounter];
  XCTAssertNotNil(counter2);
  [[[GTMSignalHandler alloc] initWithSignal:SIGUSR1
                                     target:counter2
                                     action:@selector(countSignal:)] autorelease];

  raise(SIGUSR1);
  [rl gtm_runUpToSixtySecondsWithContext:counter2];

  XCTAssertEqual([counter count], 2);
  XCTAssertEqual([counter lastSeen], SIGWINCH);
  XCTAssertEqual([counter2 count], 1);
  XCTAssertEqual([counter2 lastSeen], SIGUSR1);

  [handler invalidate];

  // The signal is still ignored (so we shouldn't die), but the
  // the handler method should not get called.
  raise(SIGWINCH);
  [rl runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.2]];

  XCTAssertEqual([counter count], 2);
  XCTAssertEqual([counter lastSeen], SIGWINCH);
  XCTAssertEqual([counter2 count], 1);
  XCTAssertEqual([counter2 lastSeen], SIGUSR1);

}

- (void)testIgnore {
  SignalCounter *counter = [SignalCounter signalCounter];
  XCTAssertNotNil(counter);

  [[[GTMSignalHandler alloc] initWithSignal:SIGUSR1
                                     target:counter
                                     action:NULL] autorelease];

  raise(SIGUSR1);
  NSRunLoop *rl = [NSRunLoop currentRunLoop];
  [rl runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.2]];
  XCTAssertEqual([counter count], 0);

}

@end
