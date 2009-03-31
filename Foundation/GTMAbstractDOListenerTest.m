//
//  GTMAbstractDOListenerTest.m
//
//  Copyright 2006-2009 Google Inc.
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
#import "GTMAbstractDOListener.h"

// Needed for GTMIsGarbageCollectionEnabled
#import "GTMGarbageCollection.h"

// Needed for GTMUnitTestDevLog expectPattern
#import "GTMUnitTestDevLog.h"

// Used for request/reply timeouts
#define kDefaultTimeout 0.5

// Used when waiting for something to shutdown
#define kDelayTimeout 30.0

enum {
  kGTMAbstractDOConditionWaiting = 123,
  kGTMAbstractDOConditionReceivedMessage
};

#pragma mark -
#pragma mark Test Protocols

@protocol TestServerDOProtocol
- (oneway void)testCommand;
- (in bycopy NSNumber *)delayResponseForTime:(in byref NSNumber *)delay;
@end

@protocol TestServerEvilDOProtocol
// This command is not implemented, but is declared to remove all compiler
// warnings.
//
- (oneway void)evilCommand;
@end

@protocol TestServerDelegateProtocol
- (void)clientSentMessage;
@end

#pragma mark -
#pragma mark Test Server

@interface TestServer : GTMAbstractDOListener<TestServerDOProtocol> {
 @private
  __weak id delegate_;
}
- (void)setDelegate:(id)delegate;
@end

@implementation TestServer

- (void)setDelegate:(id)delegate {
  delegate_ = delegate;
}

- (in bycopy NSNumber *)delayResponseForTime:(in byref NSNumber *)delay {
  NSDate *future = [NSDate dateWithTimeIntervalSinceNow:[delay doubleValue]];
  [NSThread sleepUntilDate:future];
  return [NSNumber numberWithDouble:kDefaultTimeout];
}

- (oneway void)testCommand {
  [delegate_ performSelector:@selector(clientSentMessage)];
}

@end

#pragma mark -
#pragma mark Test Client

@interface TestClient : NSObject {
 @private
  id proxy_;
  NSString *serverName_;
}
- (id)initWithName:(NSString *)name;
- (id)connect;
- (void)disconnect;
@end

@implementation TestClient
- (id)initWithName:(NSString *)name {
  serverName_ = [[NSString alloc] initWithString:name];
  if (!serverName_) {
    [self release];
    self = nil;
  }
  return self;
}

- (void)finalize {
  [self disconnect];
  [super finalize];
}

- (void)dealloc {
  [self disconnect];
  [serverName_ release];
  [super dealloc];
}

- (id)connect {
  NSConnection *connection =
    [NSConnection connectionWithRegisteredName:serverName_ host:nil];

  [connection setReplyTimeout:kDefaultTimeout];
  [connection setRequestTimeout:kDefaultTimeout];

  @try {
    proxy_ = [[connection rootProxy] retain];
  } @catch (NSException *e) {
    [self disconnect];
  }
  return proxy_;
}

- (void)disconnect {
  NSConnection *connection =
    [NSConnection connectionWithRegisteredName:serverName_ host:nil];
  [connection invalidate];
  [proxy_ release];
  proxy_ = nil;
}

@end

#pragma mark -
#pragma mark Tests

@interface GTMAbstractDOListenerTest : GTMTestCase<TestServerDelegateProtocol> {
 @private
  NSConditionLock *lock_;
}
@end

@implementation GTMAbstractDOListenerTest

- (void)clientSentMessage {
  NSDate *future = [NSDate dateWithTimeIntervalSinceNow:kDefaultTimeout];
  STAssertTrue([lock_ lockWhenCondition:kGTMAbstractDOConditionWaiting
                             beforeDate:future], @"Unable to acquire lock "
               @"for client send message.  This is BAD!");
  [lock_ unlockWithCondition:kGTMAbstractDOConditionReceivedMessage];
}

- (void)testAbstractDOListenerProtocol {
  lock_ =
    [[NSConditionLock alloc] initWithCondition:kGTMAbstractDOConditionWaiting];
  [lock_ autorelease];

  NSString *serverName = @"ProtoTest";

  // Build and start the server
  TestServer *listener =
    [[TestServer alloc] initWithRegisteredName:serverName
                                      protocol:@protocol(TestServerDOProtocol)];
  [listener autorelease];
  [listener setDelegate:self];
  [GTMUnitTestDevLog expectPattern:@"listening on.*"];
  [listener runInCurrentThread];

  // Connect with our simple client
  TestClient *client =
    [[[TestClient alloc] initWithName:serverName] autorelease];
  id proxy = [client connect];
  STAssertNotNil(proxy, @"should have a proxy object");

  [proxy testCommand];

  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:kDelayTimeout];
  while (![lock_ tryLockWhenCondition:kGTMAbstractDOConditionReceivedMessage] &&
         ([timeout compare:[NSDate date]] == NSOrderedDescending)) {
    NSDate* runUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
  }

  STAssertFalse([lock_ tryLockWhenCondition:kGTMAbstractDOConditionWaiting],
                @"A message was never received from the client.");

  STAssertThrows([proxy evilCommand],
                  @"An exception should have been thrown for a method not in"
                  @"the specified protocol.");

  [client disconnect];
  [listener shutdown];

  STAssertNil([listener connection], @"The connection should be nil after "
              @"shutdown.");

  // We are done with the lock.
  [lock_ unlockWithCondition:kGTMAbstractDOConditionWaiting];
}

- (void)testAbstractDOListenerRequestTimeout {
  NSString *serverName = @"RequestTimeoutTest";

  // Build and start the server
  TestServer *listener =
    [[TestServer alloc] initWithRegisteredName:serverName
                                      protocol:@protocol(TestServerDOProtocol)];
  [listener autorelease];
  [listener setReplyTimeout:kDefaultTimeout];
  [listener setRequestTimeout:kDefaultTimeout];
  [listener setThreadHeartRate:0.25];
  [GTMUnitTestDevLog expectPattern:@"listening on.*"];
  [listener runInNewThreadWithErrorTarget:nil
                                 selector:NULL
                       withObjectArgument:nil];

  // It will take a little while for the new thread to spin up and start
  // listening.  We will spin here and wait for it to come on-line.
  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:kDelayTimeout];
  while (![listener connection] &&
         ([timeout compare:[NSDate date]] == NSOrderedDescending)) {
    NSDate *waitTime = [NSDate dateWithTimeIntervalSinceNow:0.05];
    [[NSRunLoop currentRunLoop] runUntilDate:waitTime];
  }

  STAssertNotNil([listener connection],
                 @"The server never created a connection.");

  // Connect with our simple client
  TestClient *client =
    [[[TestClient alloc] initWithName:serverName] autorelease];
  id proxy = [client connect];
  STAssertNotNil(proxy, @"should have a proxy object");

  NSNumber *overDelay = [NSNumber numberWithDouble:(kDefaultTimeout + 0.25)];
  STAssertThrows([proxy delayResponseForTime:overDelay],
                 @"An exception should have been thrown for the response taking"
                 @"longer than the replyTimout.");

  [client disconnect];
  [listener shutdown];

  timeout = [NSDate dateWithTimeIntervalSinceNow:kDelayTimeout];
  while ([listener connection] &&
         ([timeout compare:[NSDate date]] == NSOrderedDescending)) {
    NSDate *waitTime = [NSDate dateWithTimeIntervalSinceNow:0.05];
    [[NSRunLoop currentRunLoop] runUntilDate:waitTime];
  }

  STAssertNil([listener connection], @"The connection should be nil after "
              @"shutdown.");
}

- (void)testAbstractDOListenerRelease {
  NSUInteger listenerCount = [[GTMAbstractDOListener allListeners] count];
  GTMAbstractDOListener *listener =
    [[GTMAbstractDOListener alloc] initWithRegisteredName:@"FOO"
                                                 protocol:@protocol(NSObject)
                                                     port:[NSPort port]];
  STAssertNotNil(listener, nil);

  // We throw an autorelease pool here because allStores does a couple of
  // autoreleased retains on us which would screws up our retain count
  // numbers.
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  STAssertEquals([[GTMAbstractDOListener allListeners] count],
                 listenerCount + 1, nil);
  [pool drain];

  if (!GTMIsGarbageCollectionEnabled()) {
    // Not much point with GC on.
    STAssertEquals([listener retainCount], (NSUInteger)1, nil);
  }

  [listener release];
  if (!GTMIsGarbageCollectionEnabled()) {
    STAssertEquals([[GTMAbstractDOListener allListeners] count], listenerCount,
                   nil);
  }
}

@end
