//
//  GTMNSView+UnitTesting.m
//  
//  Category for making unit testing of graphics/UI easier.
//  Allows you to save a view out to a TIFF file, and compare a view
//  with a previously stored representation to make sure it hasn't changed.
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

#import "GTMNSView+UnitTesting.h"
#import <SenTestingKit/SenTestingKit.h>
#import "GTMGeometryUtils.h"

//  A view that allows you to delegate out drawing using the formal
//  GTMUnitTestViewDelegate protocol above. This is useful when writing up unit
//  tests for visual elements.
//  Your test will often end up looking like this:
//  - (void)testFoo {
//   GTMAssertDrawingEqualToFile(self, NSMakeSize(200, 200), @"Foo", nil, nil);
//  }
//  and your testSuite will also implement the unitTestViewDrawRect method to do
//  it's actual drawing. The above creates a view of size 200x200 that draws
//  it's content using |self|'s unitTestViewDrawRect method and compares it to
//  the contents of the file Foo.tif to make sure it's valid
@implementation GTMUnitTestView

- (id)initWithFrame:(NSRect)frame drawer:(id<GTMUnitTestViewDrawer>)drawer contextInfo:(void*)contextInfo{
  self = [super initWithFrame:frame];
  if (self != nil) {
    drawer_ = [drawer retain];
    contextInfo_ = contextInfo;
  }
  return self;
}

- (void) dealloc {
  [drawer_ release];
  [super dealloc];
}


- (void)drawRect:(NSRect)rect {
  [drawer_ unitTestViewDrawRect:rect contextInfo:contextInfo_];
}


@end

@implementation NSView (GTMUnitTestingAdditions) 

//  Returns an image containing a representation of the object
//  suitable for use in comparing against a master image.
//  NB this means that all colors should be from "NSDevice" color space
//  Does all of it's drawing with smoothfonts and antialiasing off
//  to avoid issues with font smoothing settings and antialias differences
//  between ppc and x86.
//
//  Returns:
//    an image of the object
- (NSImage*)unitTestImage {
  // Create up a context
  NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
  NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
  
  // Store Current Context and switch to bitmap context
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: bitmapContext];
  CGContextRef contextRef = (CGContextRef)[bitmapContext graphicsPort];
  
  // Save our state and turn off font smoothing and antialias.
  CGContextSaveGState(contextRef);
  CGContextSetShouldSmoothFonts(contextRef, false);
  CGContextSetShouldAntialias(contextRef, false);
  CGContextClearRect(contextRef, GTMNSRectToCGRect([self bounds]));
  [self displayRectIgnoringOpacity:[self bounds] inContext:bitmapContext];
  
  // Clean up and create image
  CGContextRestoreGState(contextRef);
  [NSGraphicsContext restoreGraphicsState];
  NSImage *image = [[[NSImage alloc] init] autorelease];
  [image addRepresentation:imageRep];
  return image;
}

//  Returns whether unitTestEncodeState should recurse into subviews
//  of a particular view.
//  Dan Waylonis discovered that if you have "Full keyboard access" in the
//  Keyboard & Mouse > Keyboard Shortcuts preferences pane set to "Text boxes 
//  and Lists only" that Apple adds a set of subviews to NSTextFields. So in the 
//  case of NSTextFields we don't want to recurse into their subviews. There may 
//  be other cases like this, so instead of specializing unitTestEncodeState: to
//  look for NSTextFields, NSTextFields will just not allow us to recurse into
//  their subviews.
//
//  Returns:
//    should unitTestEncodeState pick up subview state.
- (BOOL)shouldEncodeStateRecurseIntoSubviews {
  return YES;
}

//  Encodes the state of an object in a manner suitable for comparing
//  against a master state file so we can determine whether the
//  object is in a suitable state.
//
//  Arguments:
//    inCoder - the coder to encode our state into
- (void)unitTestEncodeState:(NSCoder*)inCoder {
  [super unitTestEncodeState:inCoder];
  [inCoder encodeBool:[self isHidden] forKey:@"ViewIsHidden"];
  if ([self shouldEncodeStateRecurseIntoSubviews]) {
    NSEnumerator *subviewEnum = [[self subviews] objectEnumerator];
    NSView *subview = nil;
    int i = 0;
    while ((subview = [subviewEnum nextObject])) {
      [inCoder encodeObject:subview forKey:[NSString stringWithFormat:@"ViewSubView %d", i]];
      i = i + 1;
    }
  }
}

@end

