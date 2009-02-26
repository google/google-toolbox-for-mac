//
//  GTMTransientRootSocketProxyTest.m
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
#import "GTMTransientRootSocketProxy.h"

// Needed to get the socket port.
#import <netinet/in.h>
#import <arpa/inet.h>

#define kDefaultTimeout 5.0
#define kServerShuttingDownNotification @"serverShuttingDown"

// === Start off declaring some auxillary data structures ===

// The @protocol that we'll use for testing with.
@protocol DOSocketTestProtocol
- (oneway void)doOneWayVoid;
- (bycopy NSString *)doReturnStringBycopy;
@end

// The "server" we'll use to test the DO connection.  This server will implement
// our test protocol, and it will run in a separate thread from the main
// unit testing thread, so the DO requests can be serviced.
@interface DOSocketTestServer : NSObject <DOSocketTestProtocol> {
@private
  BOOL quit_;
  unsigned short listeningPort_;
}
- (void)runThread:(id)ignore;
- (unsigned short)listeningPort;
- (void)shutdownServer;
@end

@implementation DOSocketTestServer

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

  NSSocketPort *serverPort = [[NSSocketPort alloc] init];

  // We will need the port so we can hand if off to the client
  // The structure will get us this information.
  struct sockaddr_in addrIn =
  *(struct sockaddr_in *)[[serverPort address] bytes];
  listeningPort_ = htons(addrIn.sin_port);

  NSConnection *conn = [NSConnection connectionWithReceivePort:serverPort
                                                      sendPort:nil];
  // Port is retained by the NSConnection
  [serverPort release];
  [conn setRootObject:self];

  while (![self shouldServerQuit]) {
    NSDate* runUntil = [NSDate dateWithTimeIntervalSinceNow:0.5];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
  }

  [conn invalidate];
  [conn release];
  [nc postNotificationName:kServerShuttingDownNotification object:nil];
  [pool drain];
}

- (unsigned short)listeningPort {
  return listeningPort_;
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

@end

// === Done with auxillary data structures, now for the main test class ===

@interface GTMTransientRootSocketProxyTest : GTMTestCase {
  DOSocketTestServer *server_;
  BOOL serverOffline_;
}

@end

@implementation GTMTransientRootSocketProxyTest

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

- (void)testTransientRootSocketProxy {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  // Register for server notifications
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(serverIsShuttingDown:)
             name:kServerShuttingDownNotification
           object:nil];
  serverOffline_ = NO;

  // Setup our server.
  server_ = [[[DOSocketTestServer alloc] init] autorelease];
  [NSThread detachNewThreadSelector:@selector(runThread:)
                           toTarget:server_
                         withObject:nil];
  // Sleep for 1 second to give the new thread time to set stuff up
  [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

  // Create our NSSocketPort
  NSSocketPort *receivePort =
    [[NSSocketPort alloc] initRemoteWithTCPPort:[server_ listeningPort]
                                           host:@"localhost"];

  GTMTransientRootSocketProxy<DOSocketTestProtocol> *proxy =
    [GTMTransientRootSocketProxy rootProxyWithSocketPort:receivePort
                                                protocol:@protocol(DOSocketTestProtocol)
                                          requestTimeout:kDefaultTimeout
                                            replyTimeout:kDefaultTimeout];

  STAssertEqualObjects([proxy doReturnStringBycopy],
                       @"TestString", @"proxy should have returned "
                       @"'TestString'");

  // Redo the *exact* same test to make sure we can have multiple instances
  // in the same app.
  proxy =
    [GTMTransientRootSocketProxy rootProxyWithSocketPort:receivePort
                                                protocol:@protocol(DOSocketTestProtocol)
                                          requestTimeout:kDefaultTimeout
                                            replyTimeout:kDefaultTimeout];

  STAssertEqualObjects([proxy doReturnStringBycopy],
                       @"TestString", @"proxy should have returned "
                       @"'TestString'");

  [server_ shutdownServer];

  // Wait for the server to shutdown so we clean up nicely.  The max amount of
  // time we will wait until we abort this test.
  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:30.0];
  while (![self serverStatus] &&
         ([[[NSDate date] laterDate:timeout] isEqualToDate:timeout])) {
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:2.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
  }

  [pool drain];
}

@end
