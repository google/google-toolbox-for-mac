//
//  GTMUnitTestingUtilities.h
//
//  Copyright 2006-2008 Google Inc.
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

#import <Foundation/Foundation.h>
#import <objc/objc.h>

// Many tests need to spin the runloop and wait for an event to happen. This is
// often done by calling:
// NSDate* next = [NSDate dateWithTimeIntervalSinceNow:resolution];
// [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                          beforeDate:next];
// where |resolution| is a guess at how long it will take for the event to 
// happen. There are two major problems with this approach:
// a) By guessing we force the test to take at least |resolution| time.
// b) It makes for flaky tests in that sometimes this guess isn't good, and the 
//    test takes slightly longer than |resolution| time causing the test to post
//    a possibly false-negative failure.
// To make timing callback tests easier use this class and the 
// GTMUnitTestingAdditions additions to NSRunLoop and NSApplication.
// Your call would look something like this:
// id<GTMUnitTestingRunLoopContext> context = [self getMeAContext];
// [[NSRunLoop currentRunLoop] gtm_runUpToSixtySecondsWithContext:context];
// Then in some callback method within your test you would call
// [context setShouldStop:YES];
// Internally gtm_runUpToSixtySecondsWithContext will poll the runloop really
// quickly to keep test times down to a minimum, but will stop after a good time
// interval (in this case 60 seconds) for failures.
@protocol GTMUnitTestingRunLoopContext
// Return YES if the NSRunLoop (or equivalent) that this context applies to
// should stop as soon as possible.
- (BOOL)shouldStop;
@end

// Collection of utilities for unit testing
@interface GTMUnitTestingUtilities : NSObject

// Returns YES if we are currently being unittested.
+ (BOOL)areWeBeingUnitTested;

// Sets up the user interface so that we can run consistent UI unittests on
// it. This includes setting scroll bar types, setting selection colors
// setting color spaces etc so that everything is consistent across machines.
// This should be called in main, before NSApplicationMain is called.
+ (void)setUpForUIUnitTests;

// Syntactic sugar combining the above, and wrapping them in an 
// NSAutoreleasePool so that your main can look like this:
// int main(int argc, const char *argv[]) {
//   [UnitTestingUtilities setUpForUIUnitTestsIfBeingTested];
//   return NSApplicationMain(argc, argv);
// }
+ (void)setUpForUIUnitTestsIfBeingTested;

// Check if the screen saver is running. Some unit tests don't work when
// the screen saver is active.
+ (BOOL)isScreenSaverActive;

// Allows for posting either a keydown or a keyup with all the modifiers being 
// applied. Passing a 'g' with NSKeyDown and NSShiftKeyMask 
// generates two events (a shift key key down and a 'g' key keydown). Make sure
// to balance this with a keyup, or things could get confused. Events get posted 
// using the CGRemoteOperation events which means that it gets posted in the 
// system event queue. Thus you can affect other applications if your app isn't
// the active app (or in some cases, such as hotkeys, even if it is).
//  Arguments:
//    type - Event type. Currently accepts NSKeyDown and NSKeyUp
//    keyChar - character on the keyboard to type. Make sure it is lower case.
//              If you need upper case, pass in the NSShiftKeyMask in the
//              modifiers. i.e. to generate "G" pass in 'g' and NSShiftKeyMask.
//              to generate "+" pass in '=' and NSShiftKeyMask.
//    cocoaModifiers - an int made up of bit masks. Handles NSAlphaShiftKeyMask,
//                    NSShiftKeyMask, NSControlKeyMask, NSAlternateKeyMask, and
//                    NSCommandKeyMask
+ (void)postKeyEvent:(NSEventType)type 
           character:(CGCharCode)keyChar 
           modifiers:(UInt32)cocoaModifiers;

// Syntactic sugar for posting a keydown immediately followed by a key up event
// which is often what you really want. 
//  Arguments:
//    keyChar - character on the keyboard to type. Make sure it is lower case.
//              If you need upper case, pass in the NSShiftKeyMask in the
//              modifiers. i.e. to generate "G" pass in 'g' and NSShiftKeyMask.
//              to generate "+" pass in '=' and NSShiftKeyMask.
//    cocoaModifiers - an int made up of bit masks. Handles NSAlphaShiftKeyMask,
//                    NSShiftKeyMask, NSControlKeyMask, NSAlternateKeyMask, and
//                    NSCommandKeyMask
+ (void)postTypeCharacterEvent:(CGCharCode)keyChar 
                     modifiers:(UInt32)cocoaModifiers;

@end

// An implementation of the GTMUnitTestingRunLoopContext that is a simple
// BOOL flag. See GTMUnitTestingRunLoopContext documentation.
@interface GTMUnitTestingBooleanRunLoopContext : NSObject <GTMUnitTestingRunLoopContext> {
 @private
  BOOL shouldStop_;
}
+ (id)context;
- (BOOL)shouldStop;
- (void)setShouldStop:(BOOL)stop;
@end

// Some category methods to simplify spinning the runloops in such a way as
// to make tests less flaky, but have them complete as fast as possible.
@interface NSRunLoop (GTMUnitTestingAdditions)
// Will spin the runloop in mode until date in mode until the runloop returns
// because all sources have been removed or the current date is greater than
// |date| or [context shouldStop] returns YES.
// Return YES if the runloop was stopped because [context shouldStop] returned
// YES.
- (BOOL)gtm_runUntilDate:(NSDate *)date
                    mode:(NSString *)mode
                 context:(id<GTMUnitTestingRunLoopContext>)context;

// Calls -gtm_runUntilDate:mode:context: with mode set to NSDefaultRunLoopMode.
- (BOOL)gtm_runUntilDate:(NSDate *)date 
                 context:(id<GTMUnitTestingRunLoopContext>)context;

// Calls -gtm_runUntilDate:mode:context: with mode set to NSDefaultRunLoopMode,
// and the timeout date set to 60 seconds.
- (BOOL)gtm_runUpToSixtySecondsWithContext:(id<GTMUnitTestingRunLoopContext>)context;

@end

// Some category methods to simplify spinning the runloops in such a way as
// to make tests less flaky, but have them complete as fast as possible.
@interface NSApplication (GTMUnitTestingAdditions)
// Has NSApplication call nextEventMatchingMask repeatedly until 
// [context shouldStop] returns YES or it returns nil because the current date 
// is greater than |date|.
// Return YES if the runloop was stopped because [context shouldStop] returned
// YES.
- (BOOL)gtm_runUntilDate:(NSDate *)date 
                 context:(id<GTMUnitTestingRunLoopContext>)context;

// Calls -gtm_runUntilDate:context: with the timeout date set to 60 seconds.
- (BOOL)gtm_runUpToSixtySecondsWithContext:(id<GTMUnitTestingRunLoopContext>)context;
@end
