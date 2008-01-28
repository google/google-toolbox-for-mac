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
/// Colors will be in the device color space
+ (id)gtm_colorWithThemeTextColor:(ThemeTextColor)textColor {
  NSColor *nsTextColor = nil;
  RGBColor rgbTextColor;
  OSStatus status = GetThemeTextColor(textColor, 32, true, &rgbTextColor);
  if (status == noErr) {
    float red = rgbTextColor.red / 65535.0f;
    float green = rgbTextColor.green / 65535.0f;
    float blue = rgbTextColor.blue / 65535.0f;
    nsTextColor = [NSColor colorWithDeviceRed:red
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
/// Colors will be in the DeviceRGB color space
+ (id)gtm_colorWithThemeBrush:(ThemeBrush)brush {
  NSColor *nsBrushColor = nil;
  RGBColor rgbBrushColor;
  OSStatus status = GetThemeBrushAsColor(brush, 32, true, &rgbBrushColor);
  if (status == noErr) {
    nsBrushColor = [NSColor colorWithDeviceRed:rgbBrushColor.red / 65535.0f
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

+ (NSColor *)gtm_deviceBlackColor { /* 0.0f white */
  return [NSColor colorWithDeviceWhite:0.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceDarkGrayColor { /* 0.333 white */
  return [NSColor colorWithDeviceWhite:1.0f/3.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceLightGrayColor { /* 0.667 white */
  return [NSColor colorWithDeviceWhite:2.0f/3.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceWhiteColor { /* 1.0f white */
  return [NSColor colorWithDeviceWhite:1.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceGrayColor { /* 0.5 white */
  return [NSColor colorWithDeviceWhite:0.5f alpha:1.0f];
}

+ (NSColor *)gtm_deviceRedColor { /* 1.0f, 0.0f, 0.0f RGB */
  return [NSColor colorWithDeviceRed:1.0f green:0.0f blue: 0.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceGreenColor {	/* 0.0f, 1.0f, 0.0f RGB */
return [NSColor colorWithDeviceRed:0.0f green:1.0f blue: 0.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceBlueColor { /* 0.0f, 0.0f, 1.0f RGB */
return [NSColor colorWithDeviceRed:0.0f green:0.0f blue: 1.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceCyanColor { /* 0.0f, 1.0f, 1.0f RGB */
return [NSColor colorWithDeviceRed:0.0f green:1.0f blue: 1.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceYellowColor { /* 1.0f, 1.0f, 0.0f RGB */
return [NSColor colorWithDeviceRed:1.0f green:1.0f blue: 0.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceMagentaColor {	/* 1.0f, 0.0f, 1.0f RGB */
return [NSColor colorWithDeviceRed:1.0f green:0.0f blue: 1.0f alpha:1.0f];
}

+ (NSColor *)gtm_deviceOrangeColor { /* 1.0f, 0.5, 0.0f RGB */
return [NSColor colorWithDeviceRed:1.0f green:0.5f blue: 0.0f alpha:1.0f];
}

+ (NSColor *)gtm_devicePurpleColor { /* 0.5, 0.0f, 0.5 RGB */
return [NSColor colorWithDeviceRed:0.5f green:0.0f blue: 0.5f alpha:1.0f];
}

+ (NSColor *)gtm_deviceBrownColor {	/* 0.6, 0.4, 0.2 RGB */
return [NSColor colorWithDeviceRed:0.6f green:0.4f blue: 0.2f alpha:1.0f];
}

+ (NSColor *)gtm_deviceClearColor {	/* 0.0f white, 0.0f alpha */
  return [NSColor colorWithDeviceWhite:0.0f alpha:0.0f];
}

- (NSColor *)gtm_safeColorWithAlphaComponent:(float)alpha {
  // This mess is here because of 
  // Radar 5047862 [NSColor colorWithAlphaComponent] does NOT maintain colorspace.
  // As of 10.4.8, colorWithAlphaComponent will return an NSCalibratedRGBColor
  // instead of a NSDeviceRGBColor when you call colorWithAlphaComponent on
  // a NSDeviceRGBColor even though the docs say "Creates and returns an NSColor 
  // object that has the same color space and component values as the receiver"
  // We must use exceptions in case somebody attempts to put a pattern through
  // here. The assumption being made is that alpha is the last color component
  // which it is for all current cases.
  NSColor *newColor = nil;
    
#if (MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4)
  @try {
    int componentCount = [self numberOfComponents];
    float *components = (float*)calloc(componentCount, sizeof(float));
    if (!components) {
      NSException *exception = [NSException exceptionWithName:NSMallocException
                                                       reason:@"Unable to malloc components" 
                                                     userInfo:nil];
      @throw exception;
    }
    [self getComponents:components];
    components[componentCount - 1] = alpha;
    newColor = [NSColor colorWithColorSpace:[self colorSpace]
                                components:components count:componentCount];
    free(components);
  }
  @catch (NSException *ex) {
    // Probably passed us a pattern. I'm not even sure how Apple deals with
    // changing the alpha of a pattern color.
    newColor = [self colorWithAlphaComponent:alpha];
  }
#else
  // Radar 5047862 is fixed in Leopard.
  newColor = [self colorWithAlphaComponent:alpha];
#endif
  return newColor;
}

- (NSColor *)gtm_safeColorUsingColorSpaceName:(NSString *)colorSpaceName {
  NSColor *outColor = [self colorUsingColorSpaceName:colorSpaceName];
  if (!outColor) {
    NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                     pixelsWide:1
                                                                     pixelsHigh:1
                                                                  bitsPerSample:8
                                                                samplesPerPixel:4
                                                                       hasAlpha:YES
                                                                       isPlanar:NO
                                                                 colorSpaceName:colorSpaceName 
                                                                    bytesPerRow:0 
                                                                   bitsPerPixel:0] autorelease];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    if (context) {
      NSRect rect = NSMakeRect(0, 0, 1, 1);
      [NSGraphicsContext saveGraphicsState];
      [NSGraphicsContext setCurrentContext:context];
      [self setFill];
      NSRectFill(rect);
      [NSGraphicsContext restoreGraphicsState];
      outColor = [rep colorAtX:0 y:0];
    }
  }
  return outColor;
}
@end
