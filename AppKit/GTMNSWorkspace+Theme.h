//
//  GTMNSWorkspace+ScreenSaver.h
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

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

enum {
  // This means that we had a failure getting the style
  kThemeScrollBarArrowsInvalid = -1,
  // This is the "missing" scroll bar arrow style that some people use
  kThemeScrollBarArrowsDouble = 2
};

/// Category for interacting with the screen saver
@interface NSWorkspace (GTMWorkspaceThemeAddition)

// returns one of the kThemeAppearance... constants as an autoreleased NSString
// tells you whether we are running under blue or graphite
- (NSString*)gtm_themeAppearance;

// Returns how the user has their scroll bars configured.
- (ThemeScrollBarArrowStyle)gtm_themeScrollBarArrowStyle;
@end

