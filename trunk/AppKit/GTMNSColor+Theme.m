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

#import "GTMNSColor+Theme.h"

@implementation NSColor (GTMColorThemeAdditions)

/// Create up an NSColor based on a Theme Text Color
/// Colors will be in the CalibratedRGB color space
+ (id)gtm_colorWithThemeTextColor:(ThemeTextColor)textColor {
  NSColor *nsTextColor = nil;
  RGBColor rgbTextColor;
  OSStatus status = GetThemeTextColor(textColor, 32, true, &rgbTextColor);
  if (status == noErr) {
    float red = rgbTextColor.red / 65535.0f;
    float green = rgbTextColor.green / 65535.0f;
    float blue = rgbTextColor.blue / 65535.0f;
    nsTextColor = [NSColor colorWithCalibratedRed:red
                                            green:green
                                             blue:blue
                                            alpha:1.0f];
  } else {
#ifdef DEBUG
    NSLog(@"Unable to create color for textcolor %d", textColor);
#endif
  }
  return nsTextColor;
}

/// Create up an NSColor based on a Theme Brush
/// Colors will be in the CalibratedRGB color space
+ (id)gtm_colorWithThemeBrush:(ThemeBrush)brush {
  NSColor *nsBrushColor = nil;
  RGBColor rgbBrushColor;
  OSStatus status = GetThemeBrushAsColor(brush, 32, true, &rgbBrushColor);
  if (status == noErr) {
    nsBrushColor = [NSColor colorWithCalibratedRed:rgbBrushColor.red / 65535.0f
                                             green:rgbBrushColor.green / 65535.0f
                                              blue:rgbBrushColor.blue / 65535.0f
                                             alpha:1.0f];
  } else {
#ifdef DEBUG
    NSLog(@"Unable to create color for brushcolor %d", brush);
#endif
  }
  return nsBrushColor;
}
@end
