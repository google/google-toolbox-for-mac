//
//  GTMTransientRootSocketProxy.m
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

#import "GTMTransientRootSocketProxy.h"
#import "GTMObjC2Runtime.h"

@interface GTMTransientRootSocketProxy (ProtectedMethods)
// Returns an NSConnection for NSSocketPorts.  This method overrides the one in
// the GTMTransientRootProxy which allows us to create a connection with a
// NSSocketPort.
//
- (NSConnection *)makeConnection;
@end



@implementation GTMTransientRootSocketProxy

+ (id)rootProxyWithSocketPort:(NSSocketPort *)port
                     protocol:(Protocol *)protocol
               requestTimeout:(NSTimeInterval)requestTimeout
                 replyTimeout:(NSTimeInterval)replyTimeout {
  return [[[self alloc] initWithSocketPort:port
                                  protocol:protocol
                            requestTimeout:requestTimeout
                              replyTimeout:replyTimeout] autorelease];
}

- (id)initWithSocketPort:(NSSocketPort *)port
                protocol:(Protocol *)protocol
          requestTimeout:(NSTimeInterval)requestTimeout
            replyTimeout:(NSTimeInterval)replyTimeout {
  if (!port || !protocol) {
    [self release];
    return nil;
  }

  requestTimeout_ = requestTimeout;
  replyTimeout_ = replyTimeout;

  port_ = [port retain];

  protocol_ = protocol;  // Protocols can't be retained
  return self;
}

- (void)dealloc {
  [port_ release];
  [super dealloc];
}

@end

@implementation GTMTransientRootSocketProxy (ProtectedMethods)

- (NSConnection *)makeConnection {
  return [NSConnection connectionWithReceivePort:nil sendPort:port_];
}

@end
