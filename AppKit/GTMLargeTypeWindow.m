//
//  GTMLargeTypeWindow.m
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

#import "GTMLargeTypeWindow.h"
#import "GTMGeometryUtils.h"
#import "GTMNSBezierPath+RoundRect.h"


// Amount of time to fade the window in or out
const NSTimeInterval kGTMLargeTypeWindowFadeTime = 0.333;

// How far to inset the text from the edge of the window
static const CGFloat kEdgeInset = 16.0;

// Give us an alpha value for our backing window
static const CGFloat kTwoThirdsAlpha = 0.66;

@interface GTMLargeTypeBackgroundView : NSView 
@end

@interface GTMLargeTypeWindow (GTMLargeTypeWindowPrivate)
+ (CGFloat)displayWidth;
- (void)startFadeInAnimation;
@end

@implementation GTMLargeTypeWindow
- (id)initWithString:(NSString *)string {
  if ([string length] == 0) {
    _GTMDevLog(@"GTMLargeTypeWindow got an empty string");
    [self release];
    return nil;
  }
  CGFloat displayWidth = [[self class] displayWidth];
  NSMutableAttributedString *attrString
    = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
  
  // Try and find a size that fits without iterating too many times.
  // We start going 50 pixels at a time, then 10, then 1
  int size = -26;  // start at 24 (-26 + 50)
  int offsets[] = { 50, 10, 1 };
  for (size_t i = 0; i < sizeof(offsets) / sizeof(int); ++i) {
    for(size = size + offsets[i]; size >= 24 && size < 300; size += offsets[i]) {
      NSFont *textFont = [NSFont boldSystemFontOfSize:size];
      NSDictionary *fontAttr 
        = [NSDictionary dictionaryWithObject:textFont 
                                      forKey:NSFontAttributeName];
      NSSize textSize = [string sizeWithAttributes:fontAttr];
      if (textSize.width > displayWidth) {
        size = size - offsets[i];
        break;
      }
    }
  }
  
  // Bounds check our values
  if (size > 300) {
    size = 300;
  } else if (size < 24) {
    size = 24;
  }
  
  NSRange fullRange = NSMakeRange(0, [string length]);
  [attrString addAttribute:NSFontAttributeName 
                     value:[NSFont boldSystemFontOfSize:size] 
                     range:fullRange];
  [attrString addAttribute:NSForegroundColorAttributeName 
                     value:[NSColor whiteColor] 
                     range:fullRange];
  
  NSMutableParagraphStyle *style 
    = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
  [style setAlignment:NSCenterTextAlignment];
  [attrString addAttribute:NSParagraphStyleAttributeName 
                     value:style 
                     range:fullRange];
  
  NSShadow *textShadow = [[[NSShadow alloc] init] autorelease];
  [textShadow setShadowOffset:NSMakeSize( 5, -5 )];
  [textShadow setShadowBlurRadius:10];
  [textShadow setShadowColor:[NSColor colorWithCalibratedWhite:0 
                                                         alpha:kTwoThirdsAlpha]];
  [attrString addAttribute:NSShadowAttributeName 
                     value:textShadow 
                     range:fullRange];
  return [self initWithAttributedString:attrString];
}

- (id)initWithAttributedString:(NSAttributedString *)attrString {
  if ([attrString length] == 0) {
    _GTMDevLog(@"GTMLargeTypeWindow got an empty string");
    [self release];
    return nil;
  }
  CGFloat displayWidth =[[self class] displayWidth];
  NSRect frame = NSMakeRect(0, 0, displayWidth, 0);
  NSTextView *textView = [[[NSTextView alloc] initWithFrame:frame] autorelease];
  [textView setEditable:NO];
  [textView setSelectable:NO];
  [textView setDrawsBackground:NO];
  [[textView textStorage] setAttributedString:attrString];
  [textView sizeToFit];
  
  return [self initWithContentView:textView];
}

- (id)initWithImage:(NSImage*)image {
  if (!image) {
    _GTMDevLog(@"GTMLargeTypeWindow got an empty image");
    [self release];
    return nil;
  }
  NSRect rect = GTMNSRectOfSize([image size]);
  NSImageView *imageView 
    = [[[NSImageView alloc] initWithFrame:rect] autorelease];
  [imageView setImage:image];
  return [self initWithContentView:imageView];
}

- (id)initWithContentView:(NSView *)view {
  NSRect bounds = NSZeroRect;
  if (view) {
    bounds = [view bounds];
  }
  if (bounds.size.height <= 0 || bounds.size.width <= 0) {
    _GTMDevLog(@"GTMLargeTypeWindow got an empty view");
    [self release];
    return nil;
  }
  NSRect screenRect = [[NSScreen mainScreen] frame];
  NSRect windowRect = GTMNSAlignRectangles([view frame], 
                                           screenRect,
                                           GTMRectAlignCenter);
  windowRect = NSInsetRect(windowRect, -kEdgeInset, -kEdgeInset);
  windowRect = NSIntegralRect(windowRect);
  NSUInteger mask = NSBorderlessWindowMask | NSNonactivatingPanelMask;
  self = [super initWithContentRect:windowRect
                          styleMask:mask
                            backing:NSBackingStoreBuffered
                              defer:NO];
  if (self) {
    [self setFrame:GTMNSAlignRectangles(windowRect, 
                                        screenRect,
                                        GTMRectAlignCenter)
           display:YES];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];
    [self setLevel:NSFloatingWindowLevel];
    [self setHidesOnDeactivate:NO];

    GTMLargeTypeBackgroundView *content 
      = [[[GTMLargeTypeBackgroundView alloc] initWithFrame:NSZeroRect] 
         autorelease];
    [self setHasShadow:YES];
    [self setContentView:content];
    [self setAlphaValue:0];
    [self setIgnoresMouseEvents:YES];
    [view setFrame:GTMNSAlignRectangles([view frame], 
                                        [content frame],
                                        GTMRectAlignCenter)];
    [content addSubview:view];
    [self setInitialFirstResponder:view];
  }
  return self;
}

- (void)copy:(id)sender {
  id firstResponder = [self initialFirstResponder];
  if ([firstResponder respondsToSelector:@selector(textStorage)]) {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pb setString:[[firstResponder textStorage] string]
        forType:NSStringPboardType];
  }
}

- (BOOL)canBecomeKeyWindow { 
  return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
  [self close];
}

- (void)resignKeyWindow {
  [super resignKeyWindow];
  if([self isVisible]) {
    [self close];
  }
}

- (void)makeKeyAndOrderFront:(id)sender {
  [self startFadeInAnimation];
  [super makeKeyAndOrderFront:sender];
}

- (void)orderFront:(id)sender {
  [self startFadeInAnimation];
  [super orderFront:sender];
}

- (void)orderOut:(id)sender {
  NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:
                           self, NSViewAnimationTargetKey,
                           NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
                           nil];
  NSArray *animation = [NSArray arrayWithObject:fadeOut];
  NSViewAnimation *viewAnim 
    = [[[NSViewAnimation alloc] initWithViewAnimations:animation] autorelease];
  [viewAnim setDuration:kGTMLargeTypeWindowFadeTime];
  [viewAnim startAnimation];
  NSDate *fadeOutDate 
    = [NSDate dateWithTimeIntervalSinceNow:kGTMLargeTypeWindowFadeTime];
  // We have a local run loop because if this is called as part of a close
  // our window will be hidden immediately before it has a chance to fade.
  [[NSRunLoop currentRunLoop] runUntilDate:fadeOutDate]; 
}  

+ (CGFloat)displayWidth {
  NSRect screenRect = [[NSScreen mainScreen] frame];
  // This is just a rough calculation to make us fill a good proportion
  // of the main screen.
  return NSWidth( screenRect ) * 11.0 / 12.0 - 2.0 * kEdgeInset;
}

- (void)startFadeInAnimation {
  // If we aren't already fully visible, start fading us in.
  if ([self alphaValue] < 1.0) {
    NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:
                            self, NSViewAnimationTargetKey,
                            NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
                            nil];
    NSArray *animation = [NSArray arrayWithObject:fadeIn];
    NSViewAnimation *viewAnim 
      = [[[NSViewAnimation alloc] initWithViewAnimations:animation] autorelease];
    [viewAnim setDuration:kGTMLargeTypeWindowFadeTime];
    [viewAnim startAnimation];
  }
}
@end

@implementation GTMLargeTypeBackgroundView

- (BOOL)isOpaque {
  return NO;
}

- (void)drawRect:(NSRect)rect {
  [[NSColor colorWithDeviceWhite:0 alpha:kTwoThirdsAlpha] set];
  rect = [self bounds];
  
  NSBezierPath *roundRect = [NSBezierPath bezierPath];
  CGFloat minRadius = MIN(NSWidth(rect), NSHeight(rect)) * 0.5f;
  
  [roundRect gtm_appendBezierPathWithRoundRect:rect 
                                  cornerRadius:MIN(minRadius, 32)];
  [roundRect addClip];
  NSRectFill(rect);
  [super drawRect:rect];
}

@end
