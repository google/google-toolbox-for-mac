//
//  GMTransientRootProxyTest.m
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
#import "GTMTransientRootProxy.h"
#import "GTMUnitTestDevLog.h"

#define kDefaultTimeout 5.0
#define kServerShuttingDownNotification @"serverShuttingDown"

// === Start off declaring some auxillary data structures ===
static NSString *const kTestServerName = @"test";

// The @protocol that we'll use for testing with.
@protocol DOTestProtocol
- (oneway void)doOneWayVoid;
- (bycopy NSString *)doReturnStringBycopy;
- (void)throwException;
@end

// The "server" we'll use to test the DO connection.  This server will implement
// our test protocol, and it will run in a separate thread from the main 
// unit testing thread, so the DO requests can be serviced.
@interface DOTestServer : NSObject <DOTestProtocol> {
 @private
  BOOL quit_;
}
- (void)runThread:(id)ignore;
- (void)shutdownServer;
@end

@implementation DOTestServer

- (BOOL)shouldServerQuit {
  BOOL returnValue = NO;
  @synchronized(self) {
    returnValue = quit_;
  }
  return returnValue;
}

- (void)runThread:(id)ignore {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  quit_ = NO;

  NSConnection *conn = [NSConnection defaultConnection];
  [conn setRootObject:self];
  if (![conn registerName:kTestServerName]) {
    _GTMDevLog(@"Failed to register DO root object with name '%@'",
               kTestServerName);
    // We hit an error, we are shutting down.
    quit_ = YES;
  }

  while (![self shouldServerQuit]) {
    NSDate* runUntil = [NSDate dateWithTimeIntervalSinceNow:0.5];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
  }

  [conn invalidate];
  [conn release];
  [nc postNotificationName:kServerShuttingDownNotification object:nil];
  [pool drain];
}

- (oneway void)doOneWayVoid {
  // Do nothing
}
- (bycopy NSString *)doReturnStringBycopy {
  return @"TestString";
}

- (void)shutdownServer {
  @synchronized(self) {
    quit_ = YES;
  }
}

- (void)throwException {
  [NSException raise:@"testingException" format:@"for the unittest"];
}

@end

// === Done with auxillary data structures, now for the main test class ===

@interface GTMTransientRootProxyTest : GTMTestCase {
 @private
  DOTestServer *server_;
  BOOL serverOffline_;
}
@end

@implementation GTMTransientRootProxyTest

- (void)serverIsShuttingDown:(NSNotification *)note {
  @synchronized(self) {
    serverOffline_ = YES;
  }
}

- (BOOL)serverStatus {
  BOOL returnValue = NO;
  @synchronized(self) {
    returnValue = serverOffline_;
  }
  return returnValue;
}

- (void)testTransientRootProxy {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  // Register for server notifications
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(serverIsShuttingDown:)
             name:kServerShuttingDownNotification
           object:nil];
  serverOffline_ = NO;

  // Setup our server.
  server_ = [[[DOTestServer alloc] init] autorelease];
  [NSThread detachNewThreadSelector:@selector(runThread:)
                           toTarget:server_
                         withObject:nil];
  // Sleep for 1 second to give the new thread time to set stuff up
  [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

  GTMTransientRootProxy<DOTestProtocol> *proxy =
    [GTMTransientRootProxy rootProxyWithRegisteredName:kTestServerName
                                                  host:nil
                                              protocol:@protocol(DOTestProtocol)
                                        requestTimeout:kDefaultTimeout
                                          replyTimeout:kDefaultTimeout];

  STAssertEqualObjects([proxy doReturnStringBycopy],
                       @"TestString", @"proxy should have returned "
                       @"'TestString'");

  // Redo the *exact* same test to make sure we can have multiple instances
  // in the same app.
  proxy =
    [GTMTransientRootProxy rootProxyWithRegisteredName:kTestServerName
                                                  host:nil
                                              protocol:@protocol(DOTestProtocol)
                                        requestTimeout:kDefaultTimeout
                                          replyTimeout:kDefaultTimeout];
  STAssertEqualObjects([proxy doReturnStringBycopy],
                       @"TestString", @"proxy should have returned "
                       @"'TestString'");

  // Test the GTMRootProxyCatchAll within this test so we don't have to rebuild
  // the server again.

  GTMRootProxyCatchAll<DOTestProtocol> *catchProxy =
    [GTMRootProxyCatchAll rootProxyWithRegisteredName:kTestServerName
                                                 host:nil
                                             protocol:@protocol(DOTestProtocol)
                                       requestTimeout:kDefaultTimeout
                                         replyTimeout:kDefaultTimeout];

  [GTMUnitTestDevLog expectString:@"Proxy for invoking throwException has "
     @"caught and is ignoring exception: [NOTE: this exception originated in "
     @"the server.]\nfor the unittest"];
  id e = nil;
  @try {
    // Has the server throw an exception
    [catchProxy throwException];
  } @catch (id ex) {
    e = ex;
  }
  STAssertNil(e, @"The GTMRootProxyCatchAll did not catch the exception: %@.", e);

  proxy =
    [GTMTransientRootProxy rootProxyWithRegisteredName:@"FAKE_SERVER"
                                                  host:nil
                                              protocol:@protocol(DOTestProtocol)
                                        requestTimeout:kDefaultTimeout
                                          replyTimeout:kDefaultTimeout];
  STAssertNotNil(proxy, @"proxy shouldn't be nil, even when registered w/ a "
                 @"fake server");
  STAssertFalse([proxy isConnected], @"the proxy shouldn't be connected due to "
                @"the fake server");

  [server_ shutdownServer];

  // Wait for the server to shutdown so we clean up nicely.
  // The max amount of time we will wait until we abort this test.
  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:30.0];
  while (![self serverStatus] &&
         ([[[NSDate date] laterDate:timeout] isEqualToDate:timeout])) {
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:2.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
  }

  [pool drain];
}

@end
