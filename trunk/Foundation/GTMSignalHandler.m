//
//  GTMSignalHandler.m
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

#import "GTMSignalHandler.h"
#import "GTMDefines.h"

#import <sys/event.h>  // for kqueue() and kevent
#import "GTMDebugSelectorValidation.h"

// Simplifying assumption: No more than one handler for a particular signal is
// alive at a time.  When the second signal is registered, kqueue just updates
// the info about the first signal, which makes -dealloc time complicated (what
// happens when handler1(SIGUSR1) is released before handler2(SIGUSR1)?).  This
// could be solved by having one kqueue per signal, or keeping a list of
// handlers interested in a particular signal, but not really worth it for apps
// that register the handlers at startup and don't change them.


// File descriptor for the kqueue that will hold all of our signal events.
static int gSignalKQueueFileDescriptor;

// A wrapper around the kqueue file descriptor so we can put it into a
// runloop.
static CFSocketRef gRunLoopSocket;


@interface GTMSignalHandler (PrivateMethods)

// Invoke |handler_| on the |target_|, passing a boxed |signo_|.
- (void)notify;

// Wrap the file descriptor in a CFSocket and add it to the runloop so that a
// callback function will be called when there's activity on the descriptor.  In
// this case, we're interested in new stuff from the kqueue.
- (void)addFileDescriptorMonitor:(int)fd;

// Add ourselves to our global kqueue.
- (void)registerWithKQueue;

// Remove ourseves from our global kqueue.
- (void)unregisterWithKQueue;

@end  // PrivateMethods


@implementation GTMSignalHandler

-(id)init {
  // Folks shouldn't call init directly, so they get what they deserve.
  return [self initWithSignal:0 target:nil handler:NULL];
}  // init


- (id)initWithSignal:(int)signo
              target:(id)target
             handler:(SEL)handler {

  if ((self = [super init])) {

    if (signo == 0) {
      [self release];
      return nil;
    }

    signo_ = signo;
    target_ = target;  // Don't retain since target will most likely retain us.
    handler_ = handler;
    GTMAssertSelectorNilOrImplementedWithArguments(target_,
                                                   handler_,
                                                   @encode(NSNumber *),
                                                   NULL);
    
    // We're handling this signal via kqueue, so turn off the usual signal
    // handling.
    signal(signo_, SIG_IGN);

    if (handler != NULL) {
      [self registerWithKQueue];
    }
  }
  return self;
}  // initWithSignal

- (void)finalize {
  [self unregisterWithKQueue];
  
  [super finalize];
  
}  // finalize

- (void)dealloc {
  [self unregisterWithKQueue];
  
  [super dealloc];

}  // dealloc


// Cribbed from Advanced Mac OS X Programming.
static void SocketCallBack(CFSocketRef socketref, CFSocketCallBackType type,
                           CFDataRef address, const void *data, void *info) {
  struct kevent event;
  
  if (kevent(gSignalKQueueFileDescriptor, NULL, 0, &event, 1, NULL) == -1) {
    _GTMDevLog(@"could not pick up kqueue event.  Errno %d", errno);  // COV_NF_LINE
  } else {
    GTMSignalHandler *handler = (GTMSignalHandler *)event.udata;
    [handler notify];
  }

}  // SocketCallBack


// Cribbed from Advanced Mac OS X Programming
- (void)addFileDescriptorMonitor:(int)fd {
  CFSocketContext context = { 0, NULL, NULL, NULL, NULL };
  
  gRunLoopSocket = CFSocketCreateWithNative(kCFAllocatorDefault,
                                            fd,
                                            kCFSocketReadCallBack,
                                            SocketCallBack,
                                            &context);
  if (gRunLoopSocket == NULL) {
    _GTMDevLog(@"could not CFSocketCreateWithNative");  // COV_NF_LINE
    goto bailout;   // COV_NF_LINE
  }
  
  CFRunLoopSourceRef rls;
  rls = CFSocketCreateRunLoopSource(NULL, gRunLoopSocket, 0);
  if (rls == NULL) {
    _GTMDevLog(@"could not create a run loop source");  // COV_NF_LINE
    goto bailout;  // COV_NF_LINE
  }
  
  CFRunLoopAddSource(CFRunLoopGetCurrent(), rls,
                     kCFRunLoopDefaultMode);
  CFRelease(rls);
  
 bailout:
  return;
  
}  // addFileDescriptorMonitor


- (void)registerWithKQueue {
  
  // Make sure we have our kqueue.
  if (gSignalKQueueFileDescriptor == 0) {
    gSignalKQueueFileDescriptor = kqueue();

    if (gSignalKQueueFileDescriptor == -1) {
      _GTMDevLog(@"could not make signal kqueue.  Errno %d", errno);  // COV_NF_LINE
      return;  // COV_NF_LINE
    }

    // Add the kqueue file descriptor to the runloop.
    [self addFileDescriptorMonitor:gSignalKQueueFileDescriptor];
  }
  
  // Add a new event for the signal.
  struct kevent filter;
  EV_SET(&filter, signo_, EVFILT_SIGNAL, EV_ADD | EV_ENABLE | EV_CLEAR,
         0, 0, self);

  const struct timespec noWait = { 0, 0 };
  if (kevent(gSignalKQueueFileDescriptor, &filter, 1, NULL, 0, &noWait) != 0) {
    _GTMDevLog(@"could not add event for signal %d.  Errno %d", signo_, errno);  // COV_NF_LINE
  }
  
}  // registerWithKQueue


- (void)unregisterWithKQueue {
  // Short-circuit cases where we didn't actually register a kqueue event.
  if (signo_ == 0) return;
  if (handler_ == 0) return;

  struct kevent filter;
  EV_SET(&filter, signo_, EVFILT_SIGNAL, EV_DELETE, 0, 0, self);

  const struct timespec noWait = { 0, 0 };
  if (kevent(gSignalKQueueFileDescriptor, &filter, 1, NULL, 0, &noWait) != 0) {
    _GTMDevLog(@"could not remove event for signal %d.  Errno %d", signo_, errno);  // COV_NF_LINE
  }

}  // unregisterWithKQueue


- (void)notify {
  [target_ performSelector:handler_
                withObject:[NSNumber numberWithInt:signo_]];
}  // notify

@end  // GTMSignalHandler
