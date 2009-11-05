//
//  GTMTheme.m
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

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#import "GTMTheme.h"
#import "GTMNSColor+Luminance.h"
#import <QuartzCore/QuartzCore.h>

static GTMTheme *gGTMDefaultTheme = nil;
NSString *const kGTMThemeDidChangeNotification = @"GTMThemeDidChangeNotification";
NSString *const kGTMThemeBackgroundColorKey = @"GTMThemeBackgroundColor";

@interface GTMTheme ()
- (void)sendChangeNotification;
@end

@implementation NSWindow (GTMTheme)
- (id<GTMThemeDelegate>)gtm_themeDelegate {
  id delegate = nil;
  id tempDelegate = [self delegate];
  if ([tempDelegate conformsToProtocol:@protocol(GTMThemeDelegate)]) {
    delegate = tempDelegate;
  }
  if (!delegate) {
    tempDelegate = [self windowController];
    if ([tempDelegate conformsToProtocol:@protocol(GTMThemeDelegate)]) {
      delegate = tempDelegate;
    }
  }
  return delegate;
}

- (GTMTheme *)gtm_theme {
  GTMTheme *theme = nil;
  id<GTMThemeDelegate>delegate = [self gtm_themeDelegate];
  if (delegate) {
    theme = [delegate gtm_themeForWindow:self];
  }
  return theme;
}

- (NSPoint)gtm_themePatternPhase {
  NSPoint phase = NSZeroPoint;
  id<GTMThemeDelegate>delegate = [self gtm_themeDelegate];
  if (delegate) {
    phase = [delegate gtm_themePatternPhaseForWindow:self];
  }
  return phase;
}
@end

@implementation NSView (GTMTheme)
- (GTMTheme *)gtm_theme {
  return [[self window] gtm_theme];
}

- (NSPoint)gtm_themePatternPhase {
  return [[self window] gtm_themePatternPhase];
}
@end

@implementation GTMTheme

+ (void)setDefaultTheme:(GTMTheme *)theme {
  if (gGTMDefaultTheme != theme) {
    [gGTMDefaultTheme release];
    gGTMDefaultTheme = [theme retain];
    [gGTMDefaultTheme sendChangeNotification];
  }
}

+ (GTMTheme *)defaultTheme {
  @synchronized (self) {
    if (!gGTMDefaultTheme) {
      gGTMDefaultTheme = [[self alloc] init];
      [gGTMDefaultTheme bindToUserDefaults];
    }
  }
  return gGTMDefaultTheme;
}

- (void)bindToUserDefaults {
  NSUserDefaultsController * controller =
      [NSUserDefaultsController sharedUserDefaultsController];
  [self bind:@"backgroundColor"
    toObject:controller
 withKeyPath:@"values.GTMThemeBackgroundColor"
     options:[NSDictionary dictionaryWithObjectsAndKeys:
              NSUnarchiveFromDataTransformerName,
              NSValueTransformerNameBindingOption,
              nil]];

  [self bind:@"backgroundImage"
    toObject:controller
 withKeyPath:@"values.GTMThemeBackgroundImageData"
     options:[NSDictionary dictionaryWithObjectsAndKeys:
              NSUnarchiveFromDataTransformerName,
              NSValueTransformerNameBindingOption,
              nil]];
}

- (id)init {
  self = [super init];
  if (self != nil) {
    values_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)finalize {
  [self unbind:@"backgroundColor"];
  [self unbind:@"backgroundImage"];
  [super finalize];
}

- (void)dealloc {
  [self unbind:@"backgroundColor"];
  [self unbind:@"backgroundImage"];
  [values_ release];
  [super dealloc];
}

- (void)sendChangeNotification {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:kGTMThemeDidChangeNotification
                    object:self];
}

- (id)keyForSelector:(SEL)selector
               style:(GTMThemeStyle)style
               state:(GTMThemeState)state {
  return [NSString stringWithFormat:@"%p.%d.%d", selector, style, state];
}

- (id)valueForSelector:(SEL)selector
                 style:(GTMThemeStyle)style
                 state:(GTMThemeState)state {
  id value = [values_ objectForKey:
              [self keyForSelector:selector style:style state:state]];
  return value;
}

- (void)cacheValue:(id)value
       forSelector:(SEL)selector
             style:(GTMThemeStyle)style
             state:(GTMThemeState)state {
  id key = [self keyForSelector:selector style:style state:state];
  if (key && value) [values_ setObject:value forKey:key];
}

- (void)setValue:(id)value
    forAttribute:(NSString *)attribute
           style:(GTMThemeStyle)style
          state:(GTMThemeState)state {
  NSString *selectorString = [NSString stringWithFormat:@"%@ForStyle:state:",
                              attribute];
  [self cacheValue:value
       forSelector:NSSelectorFromString(selectorString)
             style:style
            state:state];
}

- (id)valueForAttribute:(NSString *)attribute 
                  style:(GTMThemeStyle)style
                  state:(GTMThemeState)state {
  NSString *selectorString = [NSString stringWithFormat:@"%@ForStyle:state:",
                              attribute];
  id key = [self keyForSelector:NSSelectorFromString(selectorString)
                          style:style 
                          state:state];
  return [values_ objectForKey:key];
}

- (void)setBackgroundColor:(NSColor *)value {
  if (backgroundColor_ != value) {
    [backgroundColor_ release];
    backgroundColor_ = [value retain];
  }
}
- (NSColor *)backgroundColor {
  // For nil, we return a color that works with a normal textured window
  if (!backgroundColor_)
    return [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
  return backgroundColor_;
}

- (void)setBackgroundImage:(NSImage *)value {
  if (backgroundImage_ != value) {
    [backgroundImage_ release];
    backgroundImage_ = [value retain];
  }
}

- (NSImage *)backgroundImage {
  return backgroundImage_;
}

- (NSImage *)backgroundImageForStyle:(GTMThemeStyle)style
                               state:(GTMThemeState)state {
  id value = [self valueForSelector:_cmd style:style state:state];
  if (value) return value;

  if (style == GTMThemeStyleWindow) {
    NSColor *color = nil;
    if (!state) {
      // TODO(alcor): dim images when disabled
      color = [NSColor colorWithPatternImage:backgroundImage_];
      // TODO(alcor): |color| is never used!

      if ((state & GTMThemeStateActiveWindow) != GTMThemeStateActiveWindow) {
        // TODO(alcor): this recursive call will also return nil since when you
        // ask for the active style, it never returns anything.
        NSImage *image =
            [self backgroundImageForStyle:style
                                    state:GTMThemeStateActiveWindow];
        NSBitmapImageRep *rep = (NSBitmapImageRep *)[image
                                               bestRepresentationForDevice:nil];
        if ([rep respondsToSelector:@selector(CGImage)]) {
          CIImage *ciimage = [CIImage imageWithCGImage:[rep CGImage]];
          CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                        keysAndValues:
                               @"inputSaturation",
                               [NSNumber numberWithFloat:0.8f],
                               @"inputBrightness",
                               [NSNumber numberWithFloat:0.2f],
                               @"inputContrast",
                               [NSNumber numberWithFloat:0.8f],
                               @"inputImage",
                               ciimage,
                               nil];

          ciimage = [filter valueForKey:@"outputImage"];

          value = [[[NSImage alloc] init] autorelease];
          [value addRepresentation:[NSCIImageRep imageRepWithCIImage:ciimage]];
        }
      }
    }
  }

  [self cacheValue:value forSelector:_cmd style:style state:state];
  return value;
}

- (NSBackgroundStyle)interiorBackgroundStyleForStyle:(GTMThemeStyle)style
                                               state:(GTMThemeState)state {
  id value = [self valueForSelector:_cmd style:style state:state];
  if (value) return [value intValue];

  NSGradient *gradient = [self gradientForStyle:style state:state];
  NSColor *color = [gradient interpolatedColorAtLocation:0.5];
  BOOL dark = [color gtm_isDarkColor];
  value = [NSNumber numberWithInt: dark ? NSBackgroundStyleLowered
                                 : NSBackgroundStyleRaised];
  [self cacheValue:value forSelector:_cmd style:style state:state];
  return [value intValue];
}

- (BOOL)styleIsDark:(GTMThemeStyle)style state:(GTMThemeState)state {
  id value = [self valueForSelector:_cmd style:style state:state];
  if (value) return [value boolValue];

  if (style == GTMThemeStyleToolBarButtonPressed) {
    value = [NSNumber numberWithBool:YES];
  } else {
    value = [NSNumber numberWithBool:[[self backgroundColor] gtm_isDarkColor]];
  }
  [self cacheValue:value forSelector:_cmd style:style state:state];
  return [value boolValue];
}

- (NSColor *)backgroundPatternColorForStyle:(GTMThemeStyle)style
                                      state:(GTMThemeState)state {
  NSColor *color = [self valueForSelector:_cmd style:style state:state];
  if (color) return color;

  NSImage *image = [self backgroundImageForStyle:style state:state];
  if (!image && backgroundColor_) {
    NSGradient *gradient = [self gradientForStyle:style state:state];
    if (gradient) {
      // create a gradient image for the background
      CGRect r = CGRectZero;
      // TODO(alcor): figure out a better way to get an image that is the right
      // size.
      r.size = CGSizeMake(4, 36);
      size_t bytesPerRow = 4 * r.size.width;

      CGColorSpaceRef space
        = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
      CGContextRef context
        = CGBitmapContextCreate(NULL,
                                r.size.width,
                                r.size.height,
                                8,
                                bytesPerRow,
                                space,
                                kCGImageAlphaPremultipliedFirst);
      CGColorSpaceRelease(space);
      NSGraphicsContext *nsContext =
        [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
      [NSGraphicsContext saveGraphicsState];
      [NSGraphicsContext setCurrentContext:nsContext];
      [gradient drawInRect:NSMakeRect(0, 0, r.size.width, r.size.height)
                     angle:270];
      [NSGraphicsContext restoreGraphicsState];

      CGImageRef cgImage = CGBitmapContextCreateImage(context);
      CGContextRelease(context);
      NSBitmapImageRep *rep = nil;
      if (cgImage) {
        rep = [[[NSBitmapImageRep alloc] initWithCGImage:cgImage]
               autorelease];
        CGImageRelease(cgImage);
      }

      image = [[[NSImage alloc] initWithSize:NSSizeFromCGSize(r.size)]
               autorelease];
      [image addRepresentation:rep];
    }
  }
  if (image)
    color = [NSColor colorWithPatternImage:image];
  [self cacheValue:color forSelector:_cmd style:style state:state];
  return color;
}

- (NSGradient *)gradientForStyle:(GTMThemeStyle)style
                           state:(GTMThemeState)state {
  NSGradient *gradient = [self valueForSelector:_cmd style:style state:state];
  if (gradient) return gradient;

  BOOL useDarkColors = backgroundImage_ != nil || style == GTMThemeStyleWindow;

  NSUInteger uses[4];
  if (useDarkColors) {
    uses[0] = GTMColorationBaseHighlight;
    uses[1] = GTMColorationBaseMidtone;
    uses[2] = GTMColorationBaseShadow;
    uses[3] = GTMColorationBasePenumbra;
  } else {
    uses[0] = GTMColorationLightHighlight;
    uses[1] = GTMColorationLightMidtone;
    uses[2] = GTMColorationLightShadow;
    uses[3] = GTMColorationLightPenumbra;
  }
  NSColor *backgroundColor = [self backgroundColor];

  BOOL active =
      (state & GTMThemeStateActiveWindow) == GTMThemeStateActiveWindow;
  switch (style) {
    case GTMThemeStyleTabBarDeselected: {
      NSColor *startColor = [backgroundColor gtm_colorAdjustedFor:uses[2]
                                                            faded:!active];
      NSColor *endColor = [backgroundColor gtm_colorAdjustedFor:uses[3]
                                                          faded:!active];

      gradient = [[[NSGradient alloc] initWithStartingColor:startColor
                                                endingColor:endColor]
                  autorelease];
      break;
    }
    case GTMThemeStyleTabBarSelected: {
      NSColor *startColor = [backgroundColor gtm_colorAdjustedFor:uses[0]
                                                            faded:!active];
      NSColor *endColor = [backgroundColor gtm_colorAdjustedFor:uses[1]
                                                          faded:!active];
      gradient = [[[NSGradient alloc] initWithStartingColor:startColor
                                                endingColor:endColor]
                  autorelease];
      break;
    }
    case GTMThemeStyleWindow: {
      CGFloat luminance = [backgroundColor gtm_luminance];

      // Adjust luminance so it never hits black
      if (luminance < 0.5) {
        CGFloat adjustment = (0.5 - luminance) / 1.5;
        backgroundColor
        = [backgroundColor gtm_colorByAdjustingLuminance:adjustment];
      }
      NSColor *startColor = [backgroundColor gtm_colorAdjustedFor:uses[1]
                                                            faded:!active];
      NSColor *endColor = [backgroundColor gtm_colorAdjustedFor:uses[2]
                                                          faded:!active];


      if (!active) {
        startColor = [startColor gtm_colorByAdjustingLuminance:0.1
                                                    saturation:0.5];
        endColor = [endColor gtm_colorByAdjustingLuminance:0.1
                                                saturation:0.5];

      }
      gradient = [[[NSGradient alloc] initWithStartingColor:startColor
                                                endingColor:endColor]
                  autorelease];
      break;
    }
    case GTMThemeStyleToolBar:
    case GTMThemeStyleToolBarButton: {
      NSColor *startColor = [backgroundColor gtm_colorAdjustedFor:uses[0]
                                                            faded:!active];
      NSColor *midColor = [backgroundColor gtm_colorAdjustedFor:uses[1]
                                                          faded:!active];
      NSColor *endColor = [backgroundColor gtm_colorAdjustedFor:uses[2]
                                                          faded:!active];
      NSColor *glowColor = [backgroundColor gtm_colorAdjustedFor:uses[3]
                                                           faded:!active];

      gradient = [[[NSGradient alloc] initWithColorsAndLocations:
                   startColor, 0.0,
                   midColor, 0.25,
                   endColor, 0.5,
                   glowColor, 0.75,
                   nil] autorelease];
      break;
    }
    case GTMThemeStyleToolBarButtonPressed: {
      NSColor *startColor = [backgroundColor
                             gtm_colorAdjustedFor:GTMColorationBaseShadow
                             faded:!active];
      NSColor *endColor = [backgroundColor
                           gtm_colorAdjustedFor:GTMColorationBaseMidtone
                           faded:!active];
      gradient = [[[NSGradient alloc] initWithStartingColor:startColor
                                                endingColor:endColor]
                  autorelease];
      break;
    }
    default:
      _GTMDevLog(@"Unexpected style: %d", style);
      break;
  }

  [self cacheValue:gradient forSelector:_cmd style:style state:state];
  return gradient;
}

- (NSColor *)strokeColorForStyle:(GTMThemeStyle)style
                           state:(GTMThemeState)state {
  NSColor *color = [self valueForSelector:_cmd style:style state:state];
  if (color) return color;
  NSColor *backgroundColor = [self backgroundColor];
  BOOL active = (state & GTMThemeStateActiveWindow)
    == GTMThemeStateActiveWindow;
  switch (style) {
    case GTMThemeStyleToolBarButton:
      color = [[backgroundColor gtm_colorAdjustedFor:GTMColorationDarkShadow
                                               faded:!active]
               colorWithAlphaComponent:0.3];
      break;
    case GTMThemeStyleToolBar:
    default:
      color = [[self backgroundColor]
                gtm_colorAdjustedFor:GTMColorationBaseShadow
                               faded:!active];
      break;
  }

  [self cacheValue:color forSelector:_cmd style:style state:state];
  return color;
}

- (NSColor *)iconColorForStyle:(GTMThemeStyle)style
                         state:(GTMThemeState)state {
  NSColor *color = [self valueForSelector:_cmd style:style state:state];
  if (color) return color;
  
  if ([self styleIsDark:style state:state]) {
    color = [NSColor whiteColor];
  } else {
    color = [NSColor blackColor];
  }
  
  [self cacheValue:color forSelector:_cmd style:style state:state];
  return color;
}

- (NSColor *)textColorForStyle:(GTMThemeStyle)style
                         state:(GTMThemeState)state {
  NSColor *color = [self valueForSelector:_cmd style:style state:state];
  if (color) return color;

  if ([self styleIsDark:style state:state]) {
    color = [NSColor whiteColor];
  } else {
    color = [NSColor blackColor];
  }

  [self cacheValue:color forSelector:_cmd style:style state:state];
  return color;
}

- (NSColor *)backgroundColorForStyle:(GTMThemeStyle)style
                               state:(GTMThemeState)state {
  NSColor *color = [self valueForSelector:_cmd style:style state:state];
  if (color) return color;

  // TODO(alcor): calculate this based off base background color
  // Generally this will be set by a theme provider
  color = [self backgroundColor];

  [self cacheValue:color forSelector:_cmd style:style state:state];
  return color;
}
@end

#endif // MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
