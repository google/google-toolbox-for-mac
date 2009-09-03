//  GTMFadeTruncatingTextFieldCell.m
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

#import "GTMFadeTruncatingTextFieldCell.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

@implementation GTMFadeTruncatingTextFieldCell
- (void)awakeFromNib {
  // Force to clipping
  [self setLineBreakMode:NSLineBreakByClipping];
}

- (id)initTextCell:(NSString *)aString {
  self = [super initTextCell:aString];
  if (self) {
    // Force to clipping
    [self setLineBreakMode:NSLineBreakByClipping];
  }
  return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  CGContextBeginTransparencyLayer(context, 0);

  [super drawInteriorWithFrame:cellFrame inView:controlView];

  // Don't complicate drawing unless we need to clip
  NSSize size = [[self attributedStringValue] size];
  if (size.width > cellFrame.size.width) {
    // Gradient is about twice our line height long
    CGFloat width = MIN(size.height * 2, NSWidth(cellFrame) / 4);

    // TODO(alcor): switch this to GTMLinearRGBShading if we ever need on 10.4
    NSColor *color = [self textColor];
    NSGradient *mask = [[NSGradient alloc]
        initWithStartingColor:color
                  endingColor:[color colorWithAlphaComponent:0.0]];

    // Draw the gradient mask
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    [mask drawFromPoint:NSMakePoint(NSMaxX(cellFrame) - width,
                                    NSMinY(cellFrame))
                toPoint:NSMakePoint(NSMaxX(cellFrame),
                                    NSMinY(cellFrame))
                options:NSGradientDrawsBeforeStartingLocation];
    [mask release];
  }
  CGContextEndTransparencyLayer(context);
}

@end

#endif
