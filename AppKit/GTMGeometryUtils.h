//
//  GTMGeometryUtils.h
//
//  Utilities for geometrical utilities such as conversions
//  between different types.
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

#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>


#pragma mark Miscellaneous

/// Calculate the distance between two points.
//
//  Args:
//    pt1 first point
//    pt2 second point
//  
//  Returns:
//    Distance
CG_INLINE float GTMDistanceBetweenPoints(NSPoint pt1, NSPoint pt2) {
  float dX = pt1.x - pt2.x;
  float dY = pt1.y - pt2.y;
  return sqrtf(dX * dX + dY * dY);
}

///  Returns the height of the main display (the one with the menu bar).
//
///  The value updates itself automatically whenever the user
///  repositions their monitors, or changes resolutions etc.
//
//  Returns:
//    height of the main display area.
float GTMGetMainDisplayHeight(void);

#pragma mark -
#pragma mark Point Conversion

///  Quickly convert from a global HIPoint to a global NSPoint.
//
///  HIPoints are relative to 0,0 in upper left;
///  NSPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: HIPoint to convert
//
//  Returns:
//    Converted NSPoint
CG_INLINE NSPoint GTMGlobalHIPointToNSPoint(HIPoint inPoint) { 
  return NSMakePoint(inPoint.x, GTMGetMainDisplayHeight() - inPoint.y); 
}

///  Quickly convert from a global NSPoint to a global HIPoint.
//
///  HIPoints are relative to 0,0 in upper left;
///  NSPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: NSPoint to convert
//
//  Returns:
//    Converted HIPoint
CG_INLINE HIPoint GTMGlobalNSPointToHIPoint(NSPoint inPoint) { 
  return CGPointMake(inPoint.x, GTMGetMainDisplayHeight() - inPoint.y); 
}

///  Quickly convert from a CGPoint to a NSPoint.
//
///  CGPoints are relative to 0,0 in lower left;
///  NSPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: CGPoint to convert
//
//  Returns:
//    Converted NSPoint
CG_INLINE NSPoint GTMCGPointToNSPoint(CGPoint inPoint) { 
  return NSMakePoint(inPoint.x, inPoint.y); 
}

///  Quickly convert from a NSPoint to a CGPoint.
//
///  CGPoints are relative to 0,0 in lower left;
///  NSPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: NSPoint to convert
//
//  Returns:
//    Converted CGPoint
CG_INLINE CGPoint GTMNSPointToCGPoint(NSPoint inPoint) { 
  return CGPointMake(inPoint.x, inPoint.y); 
}

///  Quickly convert from a global HIPoint to a global CGPoint.
//
///  HIPoints are relative to 0,0 in upper left;
///  CGPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: NSPoint to convert
//
//  Returns:
//    Converted CGPoint
CG_INLINE HIPoint GTMGlobalCGPointToHIPoint(CGPoint inPoint) { 
  return GTMGlobalNSPointToHIPoint(GTMCGPointToNSPoint(inPoint)); 
}

///  Quickly convert from a global CGPoint to a global HIPoint.
//
///  HIPoints are relative to 0,0 in upper left;
///    CGPoints are relative to 0,0 in lower left
//
//  Args: 
//    inPoint: CGPoint to convert
//
//  Returns:
//    Converted NSPoint
CG_INLINE CGPoint GTMGlobalHIPointToCGPoint(HIPoint inPoint) { 
  return GTMNSPointToCGPoint(GTMGlobalHIPointToNSPoint(inPoint)); 
}

#pragma mark -
#pragma mark Rect Conversion

///  Convert from a global NSRect to a global HIRect.
//
///  HIRect are relative to 0,0 in upper left;
///  NSRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: NSRect to convert
//
//  Returns:
//    Converted HIRect
HIRect GTMGlobalNSRectToHIRect(NSRect inRect);

///  Convert from a rect to a HIRect.
//
///  HIRect are relative to 0,0 in upper left;
///  Rect are relative to 0,0 in upper left
//
//  Args: 
//    inRect: Rect to convert
//
//  Returns:
//    Converted HIRect
HIRect GTMRectToHIRect(Rect inRect);

///  Convert from a global HIRect to a global NSRect.
//
///  NSRect are relative to 0,0 in lower left;
///  HIRect are relative to 0,0 in upper left
//
//  Args: 
//    inRect: HIRect to convert
//
//  Returns:
//    Converted NSRect
NSRect GTMGlobalHIRectToNSRect(HIRect inRect);


///  Convert from a HIRect to a Rect.
//
///  Rect are relative to 0,0 in upper left;
///  HIRect are relative to 0,0 in upper left
//
//  Args: 
//    inRect: HIRect to convert
//
//  Returns:
//    Converted Rect
Rect GTMHIRectToRect(HIRect inRect);

///  Convert from a global Rect to a global NSRect.
//
///  NSRect are relative to 0,0 in lower left;
///  Rect are relative to 0,0 in upper left
//
//  Args: 
//    inRect: Rect to convert
//
//  Returns:
//    Converted NSRect
CG_INLINE NSRect GTMGlobalRectToNSRect(Rect inRect) {
  return GTMGlobalHIRectToNSRect(GTMRectToHIRect(inRect));
}

///  Convert from a CGRect to a NSRect.
//
///  NSRect are relative to 0,0 in lower left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: CGRect to convert
//
//  Returns:
//    Converted NSRect
CG_INLINE NSRect GTMCGRectToNSRect(CGRect inRect) {
  return NSMakeRect(inRect.origin.x,inRect.origin.y,inRect.size.width,inRect.size.height);
}

///  Convert from a NSRect to a CGRect.
//
///  NSRect are relative to 0,0 in lower left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: NSRect to convert
//
//  Returns:
//    Converted CGRect
CG_INLINE CGRect GTMNSRectToCGRect(NSRect inRect) {
  return CGRectMake(inRect.origin.x,inRect.origin.y,inRect.size.width,inRect.size.height);
}

///  Convert from a global HIRect to a global CGRect.
//
///  HIRect are relative to 0,0 in upper left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: HIRect to convert
//
//  Returns:
//    Converted CGRect
CG_INLINE CGRect GTMGlobalHIRectToCGRect(HIRect inRect) {
  return GTMNSRectToCGRect(GTMGlobalHIRectToNSRect(inRect));
}

///  Convert from a global Rect to a global CGRect.
//
///  Rect are relative to 0,0 in upper left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: Rect to convert
//
//  Returns:
//    Converted CGRect
CG_INLINE CGRect GTMGlobalRectToCGRect(Rect inRect) {
  return GTMNSRectToCGRect(GTMGlobalRectToNSRect(inRect));
}

///  Convert from a global NSRect to a global Rect.
//
///  Rect are relative to 0,0 in upper left;
///  NSRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: NSRect to convert
//
//  Returns:
//    Converted Rect
CG_INLINE Rect GTMGlobalNSRectToRect(NSRect inRect) {
  return GTMHIRectToRect(GTMGlobalNSRectToHIRect(inRect));
}

///  Convert from a global CGRect to a global HIRect.
//
///  HIRect are relative to 0,0 in upper left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: CGRect to convert
//
//  Returns:
//    Converted HIRect
CG_INLINE HIRect GTMGlobalCGRectToHIRect(CGRect inRect) {
  return GTMGlobalNSRectToHIRect(GTMCGRectToNSRect(inRect));
}

///  Convert from a global CGRect to a global Rect.
//
///  Rect are relative to 0,0 in upper left;
///  CGRect are relative to 0,0 in lower left
//
//  Args: 
//    inRect: CGRect to convert
//
//  Returns:
//    Converted Rect
CG_INLINE Rect GTMGlobalCGRectToRect(CGRect inRect) {
  return GTMHIRectToRect(GTMGlobalCGRectToHIRect(inRect));
}

#pragma mark -
#pragma mark Size Conversion

///  Convert from a CGSize to an NSSize.
//
//  Args: 
//    inSize: CGSize to convert
//
//  Returns:
//    Converted NSSize
CG_INLINE NSSize GTMCGSizeToNSSize(CGSize inSize) {
  return NSMakeSize(inSize.width, inSize.height);
}

///  Convert from a NSSize to a CGSize.
//
//  Args: 
//    inSize: NSSize to convert
//
//  Returns:
//    Converted CGSize
CG_INLINE CGSize GTMNSSizeToCGSize(NSSize inSize) {
  return CGSizeMake(inSize.width, inSize.height);
}

#pragma mark -
#pragma mark Point On Rect

/// Return middle of left side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of left side of rect
CG_INLINE NSPoint GTMNSMidLeft(NSRect rect) {
  return NSMakePoint(NSMinX(rect), NSMidY(rect));
}

/// Return middle of right side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of right side of rect
CG_INLINE NSPoint GTMNSMidRight(NSRect rect) {
  return NSMakePoint(NSMaxX(rect), NSMidY(rect));
}

/// Return middle of top side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of top side of rect
CG_INLINE NSPoint GTMNSMidTop(NSRect rect) {
  return NSMakePoint(NSMidX(rect), NSMaxY(rect));
}

/// Return middle of bottom side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of bottom side of rect
CG_INLINE NSPoint GTMNSMidBottom(NSRect rect) {
  return NSMakePoint(NSMidX(rect), NSMinY(rect));
}

/// Return center of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the center of rect
CG_INLINE NSPoint GTMNSCenter(NSRect rect) {
  return NSMakePoint(NSMidX(rect), NSMidY(rect));
}

/// Return middle of left side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of left side of rect
CG_INLINE CGPoint GTMCGMidLeft(CGRect rect) {
  return CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
}

/// Return middle of right side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of right side of rect
CG_INLINE CGPoint GTMCGMidRight(CGRect rect) {
  return CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
}

/// Return middle of top side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of top side of rect
CG_INLINE CGPoint GTMCGMidTop(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
}

/// Return middle of bottom side of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the middle of bottom side of rect
CG_INLINE CGPoint GTMCGMidBottom(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
}

/// Return center of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    point located in the center of rect
CG_INLINE CGPoint GTMCGCenter(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

#pragma mark -
#pragma mark Rect-Size Conversion

/// Return size of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    size of rectangle
CG_INLINE NSSize GTMNSRectSize(NSRect rect) {
  return NSMakeSize(NSWidth(rect), NSHeight(rect));
}

/// Return size of rectangle
//
//  Args:
//    rect - rectangle
//  
//  Returns:
//    size of rectangle
CG_INLINE CGSize GTMCGRectSize(CGRect rect) {
  return CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
}

/// Return rectangle of size
//
//  Args:
//    size - size
//  
//  Returns:
//    rectangle of size (origin 0,0)
CG_INLINE NSRect GTMNSRectOfSize(NSSize size) {
  return NSMakeRect(0.0f, 0.0f, size.width, size.height);
}

/// Return rectangle of size
//
//  Args:
//    size - size
//  
//  Returns:
//    rectangle of size (origin 0,0)
CG_INLINE CGRect GTMCGRectOfSize(CGSize size) {
  return CGRectMake(0.0f, 0.0f, size.width, size.height);
}

#pragma mark -
#pragma mark Rect Scaling and Alignment

///  Scales an NSRect
//
//  Args: 
//    inRect: Rect to scale
//    xScale: fraction to scale (1.0 is 100%)
//    yScale: fraction to scale (1.0 is 100%)
//
//  Returns:
//    Converted Rect
CG_INLINE NSRect GTMNSRectScale(NSRect inRect, float xScale, float yScale) {
  return NSMakeRect(inRect.origin.x, inRect.origin.y, 
                    inRect.size.width * xScale, inRect.size.height * yScale);
}

///  Scales an CGRect
//
//  Args: 
//    inRect: Rect to scale
//    xScale: fraction to scale (1.0 is 100%)
//    yScale: fraction to scale (1.0 is 100%)
//
//  Returns:
//    Converted Rect
CG_INLINE CGRect GTMCGRectScale(CGRect inRect, float xScale, float yScale) {
  return CGRectMake(inRect.origin.x, inRect.origin.y, 
                    inRect.size.width * xScale, inRect.size.height * yScale);
}

/// Align rectangles
//
//  Args:
//    alignee - rect to be aligned
//    aligner - rect to be aligned from
NSRect GTMAlignRectangles(NSRect alignee, NSRect aligner, 
                         NSImageAlignment alignment);  

/// Align rectangles
//
//  Args:
//    alignee - rect to be aligned
//    aligner - rect to be aligned from
//    alignment - way to align the rectangles
CG_INLINE CGRect GTMCGAlignRectangles(CGRect alignee, CGRect aligner, 
                                      NSImageAlignment alignment) {
  return GTMNSRectToCGRect(GTMAlignRectangles(GTMCGRectToNSRect(alignee),
                                              GTMCGRectToNSRect(aligner),
                                              alignment));
}

/// Scale rectangle
//
//  Args:
//    scalee - rect to be scaled
//    size - size to scale to
//    scaling - way to scale the rectangle
NSRect GTMScaleRectangleToSize(NSRect scalee, NSSize size, 
                              NSImageScaling scaling);  

/// Scale rectangle
//
//  Args:
//    scalee - rect to be scaled
//    size - size to scale to
//    scaling - way to scale the rectangle
CG_INLINE CGRect GTMCGScaleRectangleToSize(CGRect scalee, CGSize size, 
                                           NSImageScaling scaling) {
  return GTMNSRectToCGRect(GTMScaleRectangleToSize(GTMCGRectToNSRect(scalee),
                                                   GTMCGSizeToNSSize(size),
                                                   scaling));
}

