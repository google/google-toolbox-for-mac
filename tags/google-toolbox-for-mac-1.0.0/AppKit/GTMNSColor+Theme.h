//
//  GTMNSColor+Theme.m
//
//  Category for working with Themes and NSColor
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

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

///  Category for working with Themes and NSColor
@interface NSColor (GTMColorThemeAdditions) 

/// Create up an NSColor based on a Theme Text Color.
/// Colors will be in the DeviceRGB color space
+ (id)gtm_colorWithThemeTextColor:(ThemeTextColor)textColor;

/// Create up an NSColor based on a Theme Brush
/// Colors will be in the DeviceRGB color space
+ (id)gtm_colorWithThemeBrush:(ThemeBrush)brush;

/// Device colors for drawing UI elements and such
+ (NSColor *)gtm_deviceBlackColor;	/* 0.0 white */
+ (NSColor *)gtm_deviceDarkGrayColor;	/* 0.333 white */
+ (NSColor *)gtm_deviceLightGrayColor;	/* 0.667 white */
+ (NSColor *)gtm_deviceWhiteColor;	/* 1.0 white */
+ (NSColor *)gtm_deviceGrayColor;		/* 0.5 white */
+ (NSColor *)gtm_deviceRedColor;		/* 1.0, 0.0, 0.0 RGB */
+ (NSColor *)gtm_deviceGreenColor;	/* 0.0, 1.0, 0.0 RGB */
+ (NSColor *)gtm_deviceBlueColor;		/* 0.0, 0.0, 1.0 RGB */
+ (NSColor *)gtm_deviceCyanColor;		/* 0.0, 1.0, 1.0 RGB */
+ (NSColor *)gtm_deviceYellowColor;	/* 1.0, 1.0, 0.0 RGB */
+ (NSColor *)gtm_deviceMagentaColor;	/* 1.0, 0.0, 1.0 RGB */
+ (NSColor *)gtm_deviceOrangeColor;	/* 1.0, 0.5, 0.0 RGB */
+ (NSColor *)gtm_devicePurpleColor;	/* 0.5, 0.0, 0.5 RGB */
+ (NSColor *)gtm_deviceBrownColor;	/* 0.6, 0.4, 0.2 RGB */
+ (NSColor *)gtm_deviceClearColor;	/* 0.0 white, 0.0 alpha */

/// default colorWithAlphaComponent has a bug where it doesn't maintain colorspace
// Radar 5047862 [NSColor colorWithAlphaComponent] does NOT maintain colorspace.
- (NSColor *)gtm_safeColorWithAlphaComponent:(float)alpha;

// gives us a color for any color space.
// Should never return nil, but will if there is an error (out of memory?)
// converting a color to a different colorspace.
// Radar 5608378 Would like theme brush value for the menu item highlight color
// Radar 5608444 colorUsingColorSpaceName doesn't work for NSDeviceRGBColorSpace and SystemColors
- (NSColor *)gtm_safeColorUsingColorSpaceName:(NSString *)colorSpaceName;
@end
