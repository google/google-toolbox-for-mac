//
//  NSWorkspace+ThemeTest.m
//
//  Copyright 2007-2008 Google Inc.
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

#import <SenTestingKit/SenTestingKit.h>
#import "GTMSenTestCase.h"
#import "GTMNSWorkspace+Theme.h"

@interface GTMNSWorkspace_ThemeTest : SenTestCase
@end

@implementation GTMNSWorkspace_ThemeTest

- (void)testThemeAppearance {
  NSString *theme = [[NSWorkspace sharedWorkspace] gtm_themeAppearance];
  STAssertNotNil(theme, nil);
  STAssertTrue([theme hasPrefix:(NSString*)kThemeAppearanceAqua], nil);
}

- (void)testThemeScrollBarArrowStyle {
  ThemeScrollBarArrowStyle style = [[NSWorkspace sharedWorkspace] gtm_themeScrollBarArrowStyle];
  STAssertLessThanOrEqual(style, (ThemeScrollBarArrowStyle)kThemeScrollBarArrowsDouble, nil);
}
@end
