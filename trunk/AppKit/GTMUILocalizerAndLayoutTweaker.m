//
//  GTMUILocalizerAndLayoutTweaker.m
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

#import "GTMUILocalizerAndLayoutTweaker.h"
#import "GTMUILocalizer.h"

// Helper that will try to do a SizeToFit on any UI items and do the special
// case handling we also need to end up with a usable UI item.  It also takes
// an offset so we can slide the item if we need to.
// Returns the change in the view's size.
static NSSize SizeToFit(NSView *view, NSPoint offset);
// Compare function for -[NSArray sortedArrayUsingFunction:context:]
static NSInteger CompareFrameX(id view1, id view2, void *context);
// Check if the view is anchored on the right (fixed right, flexable left).
static BOOL IsRightAnchored(NSView *view);

@interface GTMUILocalizerAndLayoutTweaker (PrivateMethods)
// Recursively walk the UI triggering Tweakers.
- (void)tweakView:(NSView *)view;
@end

@interface GTMWidthBasedTweaker (InternalMethods)
// Does the actual work to size and adjust the views within this Tweaker.  The
// offset is the amount this view should shift as part of it's resize.
// Returns change in this view's width.
- (CGFloat)tweakLayoutWithOffset:(NSPoint)offset;
@end

@implementation GTMUILocalizerAndLayoutTweaker

- (void)awakeFromNib {
  if (uiObject_) {
    GTMUILocalizer *localizer = localizer_;
    if (!localizer) {
      NSBundle *bundle = [GTMUILocalizer bundleForOwner:localizerOwner_];
      localizer = [[[GTMUILocalizer alloc] initWithBundle:bundle] autorelease];
    }
    [self applyLocalizer:localizer tweakingUI:uiObject_];
  }
}

- (void)applyLocalizer:(GTMUILocalizer *)localizer
            tweakingUI:(id)uiObject {
  // Localize first
  [localizer localizeObject:uiObject recursively:YES];

  // Then tweak!
  [self tweakUI:uiObject];
}

- (void)tweakUI:(id)uiObject {
  // Figure out where we start
  NSView *startView;
  if ([uiObject isKindOfClass:[NSWindow class]]) {
    startView = [(NSWindow *)uiObject contentView];
  } else {
    _GTMDevAssert([uiObject isKindOfClass:[NSView class]],
                  @"should have been a subclass of NSView");
    startView = (NSView *)uiObject;
  }
  
  // Tweak away!
  [self tweakView:startView];
}

- (void)tweakView:(NSView *)view {
  // If its a alignment box, let it do its thing, otherwise, go find boxes
  if ([view isKindOfClass:[GTMWidthBasedTweaker class]]) {
    [(GTMWidthBasedTweaker *)view tweakLayoutWithOffset:NSZeroPoint];
  } else {
    NSArray *subviews = [view subviews];
    NSView *subview = nil;
    GTM_FOREACH_OBJECT(subview, subviews) {
      [self tweakView:subview];
    }
  }
}

+ (NSSize)sizeToFitView:(NSView *)view {
  return SizeToFit(view, NSZeroPoint);
}

+ (CGFloat)sizeToFitFixedWidthTextField:(NSTextField *)textField {
  NSRect initialFrame = [textField frame];
  NSRect sizeRect = NSMakeRect(0, 0, NSWidth(initialFrame), CGFLOAT_MAX);
  NSSize newSize = [[textField cell] cellSizeForBounds:sizeRect];
  [textField setFrameSize:newSize];
  return newSize.height - NSHeight(initialFrame);
}

@end

@implementation GTMWidthBasedTweaker

- (CGFloat)changedWidth {
  return widthChange_;
}

- (CGFloat)tweakLayoutWithOffset:(NSPoint)offset {
  NSArray *subviews = [self subviews];
  if (![subviews count]) {
    widthChange_ = 0.0;
    return widthChange_;
  }

  BOOL sumMode = NO;
  NSMutableArray *rightAlignedSubViews = nil;
  NSMutableArray *rightAlignedSubViewDeltas = nil;
  if ([subviews count] > 1) {
    // Do they share left edges (within a pixel)
    if (fabs(NSMinX([[subviews objectAtIndex:0] frame]) -
             NSMinX([[subviews objectAtIndex:1] frame])) > 1.0) {
      // No, so walk them x order moving them along so they don't overlap.
      sumMode = YES;
      subviews = [subviews sortedArrayUsingFunction:CompareFrameX context:NULL];
    } else {
      // Since they are vertical, any views pinned to the right will have to be
      // shifted after we finish figuring out the final size.
      rightAlignedSubViews = [NSMutableArray array];
      rightAlignedSubViewDeltas = [NSMutableArray array];
    }
  }

  // Size our subviews
  NSView *subView;
  CGFloat finalDelta = sumMode ? 0 : -CGFLOAT_MAX;
  NSPoint subViewOffset = NSZeroPoint;
  GTM_FOREACH_OBJECT(subView, subviews) {
    if (sumMode) {
      subViewOffset.x = finalDelta;
    }
    CGFloat delta = SizeToFit(subView, subViewOffset).width;
    if (sumMode) {
      finalDelta += delta;
    } else {
      if (delta > finalDelta) {
        finalDelta = delta;
      }
    }
    // Track the right anchored subviews size changes so we can update them
    // once we know this view's size.
    if (IsRightAnchored(subView)) {
      [rightAlignedSubViews addObject:subView];
      [rightAlignedSubViewDeltas addObject:[NSNumber numberWithDouble:delta]];
    }
  }

  // Are we pinned to the right of our parent?
  BOOL rightAnchored = IsRightAnchored(self);

  // Adjust our size (turn off auto resize, because we just fixed up all the
  // objects within us).
  BOOL autoresizesSubviews = [self autoresizesSubviews];
  if (autoresizesSubviews) {
    [self setAutoresizesSubviews:NO];
  }
  NSRect selfFrame = [self frame];
  selfFrame.size.width += finalDelta;
  if (rightAnchored) {
    // Right side is anchored, so we need to slide back to the left.
    selfFrame.origin.x -= finalDelta;
  }
  selfFrame.origin.x += offset.x;
  selfFrame.origin.y += offset.y;
  [self setFrame:selfFrame];
  if (autoresizesSubviews) {
    [self setAutoresizesSubviews:autoresizesSubviews];
  }

  // Now spin over the list of right aligned view and their size changes
  // fixing up their positions so they are still right aligned in our final
  // view.
  for (NSUInteger lp = 0; lp < [rightAlignedSubViews count]; ++lp) {
    subView = [rightAlignedSubViews objectAtIndex:lp];
    CGFloat delta = [[rightAlignedSubViewDeltas objectAtIndex:lp] doubleValue];
    NSRect viewFrame = [subView frame];
    viewFrame.origin.x += -delta + finalDelta;
    [subView setFrame:viewFrame];
  }

  if (viewToSlideAndResize_) {
    NSRect viewFrame = [viewToSlideAndResize_ frame];
    if (!rightAnchored) {
      // If our right wasn't anchored, this view slides (we push it right).
      // (If our right was anchored, the assumption is the view is in front of
      // us so its x shouldn't move.)
      viewFrame.origin.x += finalDelta;
    }
    viewFrame.size.width -= finalDelta;
    [viewToSlideAndResize_ setFrame:viewFrame];
  }
  if (viewToSlide_) {
    NSRect viewFrame = [viewToSlide_ frame];
    // Move the view the same direction we moved.
    if (rightAnchored) {
      viewFrame.origin.x -= finalDelta;
    } else {
      viewFrame.origin.x += finalDelta;
    }
    [viewToSlide_ setFrame:viewFrame];
  }
  if (viewToResize_) {
    if ([viewToResize_ isKindOfClass:[NSWindow class]]) {
      NSWindow *window = (NSWindow *)viewToResize_;
      NSRect windowFrame = [window frame];
      windowFrame.size.width += finalDelta;
      [window setFrame:windowFrame display:YES];
      // For some reason the content view is resizing, but not adjusting its
      // origin, so correct it manually.
      [[window contentView] setFrameOrigin:NSMakePoint(0, 0)];
      // TODO: should we update min size?
    } else {
      NSRect viewFrame = [viewToResize_ frame];
      viewFrame.size.width += finalDelta;
      [viewToResize_ setFrame:viewFrame];
      // TODO: should we check if this view is right anchored, and adjust its
      // x position also?
    }
  }

  widthChange_ = finalDelta;
  return widthChange_;
}

@end

#pragma mark -

static NSSize SizeToFit(NSView *view, NSPoint offset) {

  // If we've got one of us within us, recurse (for grids)
  if ([view isKindOfClass:[GTMWidthBasedTweaker class]]) {
    GTMWidthBasedTweaker *widthAlignmentBox = (GTMWidthBasedTweaker *)view;
    return NSMakeSize([widthAlignmentBox tweakLayoutWithOffset:offset], 0);
  }

  NSRect oldFrame = [view frame];
  NSRect fitFrame = oldFrame;
  NSRect newFrame = oldFrame;

  if ([view isKindOfClass:[NSTextField class]] &&
      [(NSTextField *)view isEditable]) {
    // Don't try to sizeToFit because edit fields really don't want to be sized
    // to what is in them as they are for users to enter things so honor their
    // current size.
  } else {

    // Genericaly fire a sizeToFit if it has one.
    if ([view respondsToSelector:@selector(sizeToFit)]) {
      [view performSelector:@selector(sizeToFit)];
      fitFrame = [view frame];
      newFrame = fitFrame;
    }

    // -[NSButton sizeToFit] gives much worse results than IB's Size to Fit
    // option. This is the amount of padding IB adds over a sizeToFit,
    // empirically determined.
    // TODO: We need to check the type of button before doing this.
    if ([view isKindOfClass:[NSButton class]]) {
      const float kExtraPaddingAmount = 12;
      // Width is tricky, new buttons in IB are 96 wide, Carbon seems to have
      // defaulted to 70, Cocoa seems to like 82.  But we go with 96 since
      // that's what IB is doing these days.
      const float kMinButtonWidth = 96;
      newFrame.size.width = NSWidth(newFrame) + kExtraPaddingAmount;
      if (NSWidth(newFrame) < kMinButtonWidth) {
        newFrame.size.width = kMinButtonWidth;
      }
    }
  }

  // Apply the offset, and see if we need to change the frame (again).
  newFrame.origin.x += offset.x;
  newFrame.origin.y += offset.y;
  if (!NSEqualRects(fitFrame, newFrame)) {
    [view setFrame:newFrame];
  }

  // Return how much we changed size.
  return NSMakeSize(NSWidth(newFrame) - NSWidth(oldFrame),
                    NSHeight(newFrame) - NSHeight(oldFrame));
}

static NSInteger CompareFrameX(id view1, id view2, void *context) {
  CGFloat x1 = [view1 frame].origin.x;
  CGFloat x2 = [view2 frame].origin.x;
  if (x1 < x2)
    return NSOrderedAscending;
  else if (x1 > x2)
    return NSOrderedDescending;
  else
    return NSOrderedSame;
}

static BOOL IsRightAnchored(NSView *view) {
  NSUInteger autoresizing = [view autoresizingMask];
  BOOL viewRightAnchored =
   ((autoresizing & (NSViewMinXMargin | NSViewMaxXMargin)) == NSViewMinXMargin);
  return viewRightAnchored;
}
