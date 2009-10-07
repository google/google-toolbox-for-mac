//
//  GTMThemeTest.m
//
//  Copyright 2009 Google Inc.
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

#import <Cocoa/Cocoa.h>

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#import "GTMSenTestCase.h"
#import "GTMTheme.h"

@interface GTMThemeTest : GTMTestCase {
 @private
  BOOL themeNotificationCalled_;
}
@end
  
@implementation GTMThemeTest

- (void)testTheming {
  GTMTheme *theme = [GTMTheme defaultTheme];
  
  // When there are no values, use window default colors
  STAssertEqualObjects([theme backgroundColor], 
                       [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], nil);
  STAssertNil([theme backgroundImageForStyle:GTMThemeStyleWindow
                                       state:GTMThemeStateActiveWindow],
              nil);
  STAssertNil([theme backgroundImage], nil);

  NSColor *color = [NSColor redColor];
  NSData *colorData = [NSArchiver archivedDataWithRootObject:color];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:colorData forKey:kGTMThemeBackgroundColorKey];
  
  STAssertNotNil([theme textColorForStyle:GTMThemeStyleToolBar
                                    state:GTMThemeStateActiveWindow], nil);
  STAssertNotNil([theme backgroundColorForStyle:GTMThemeStyleToolBar
                                          state:GTMThemeStateActiveWindow], nil);
  STAssertNotNil([theme backgroundPatternColorForStyle:GTMThemeStyleToolBar
                                         state:GTMThemeStateActiveWindow], nil);
  STAssertNotNil([theme strokeColorForStyle:GTMThemeStyleToolBar
                                      state:GTMThemeStateActiveWindow], nil);
  STAssertNotNil([theme gradientForStyle:GTMThemeStyleToolBar
                                   state:GTMThemeStateActiveWindow], nil);
  
  STAssertEqualObjects([theme backgroundColor], color, nil);
  
  NSBackgroundStyle style
    = [theme interiorBackgroundStyleForStyle:GTMThemeStyleToolBar
                                       state:GTMThemeStateActiveWindow];
  // TODO(alcor): add more of these cases once the constants are more concrete
  STAssertEquals(style, (NSBackgroundStyle)NSBackgroundStyleRaised, nil);
  
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:
    @"GTMThemeBackgroundColor"];
}

- (void)themeDidChangeNotification:(NSNotification *)notification {
  STAssertEquals(themeNotificationCalled_, NO, nil);
  themeNotificationCalled_ = YES;
}

- (void)testPhase {
  GTMTheme *theme = [GTMTheme defaultTheme];
  STAssertEquals([theme backgroundPatternPhase], NSZeroPoint, nil);
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self 
         selector:@selector(themeDidChangeNotification:) 
             name:kGTMThemeDidChangeNotification 
           object:theme];
  themeNotificationCalled_ = NO;
  NSPoint newPhase = NSMakePoint(20, 30);
  [theme setBackgroundPatternPhase:newPhase];
  STAssertTrue(themeNotificationCalled_, nil);
  themeNotificationCalled_ = NO;
  STAssertEquals([theme backgroundPatternPhase], newPhase, nil);
  [nc removeObserver:self name:kGTMThemeDidChangeNotification object:theme];
}

@end

#endif // MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
