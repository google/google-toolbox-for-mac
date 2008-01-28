//
//  GTMGeometryUtils.m
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

#import "GTMGeometryUtils.h"

float GTMGetMainDisplayHeight(void) {
  float height = 0;
  NSArray *screens = [NSScreen screens];
  // We may have a headless machine without any screens. In this case we
  // return 0.
  if ([screens count] > 0) {
    height = NSHeight([(NSScreen*)[screens objectAtIndex: 0] frame]);
  }
  return height;
}
 

//  Rect conversion routines.
HIRect GTMGlobalNSRectToHIRect(NSRect inRect) {
  HIRect theRect;
  theRect.origin = GTMGlobalNSPointToHIPoint(inRect.origin);
  theRect.origin.y -= inRect.size.height;
  theRect.size = CGSizeMake(inRect.size.width, inRect.size.height);
  return theRect;
}


HIRect GTMRectToHIRect(Rect inRect) {
  HIRect theRect;
  theRect.origin = CGPointMake(inRect.left,inRect.top);
  theRect.size = CGSizeMake(inRect.right - inRect.left, inRect.bottom - inRect.top);
  return theRect;
}


NSRect GTMGlobalHIRectToNSRect(HIRect inRect) {
  NSRect theRect;
  theRect.origin = GTMGlobalHIPointToNSPoint(inRect.origin);
  theRect.origin.y -= inRect.size.height;
  theRect.size = NSMakeSize(inRect.size.width, inRect.size.height);
  return theRect;
}


Rect GTMHIRectToRect(HIRect inRect) {
  Rect theRect;
  theRect.left = inRect.origin.x;
  theRect.right = ceilf(inRect.origin.x + inRect.size.width);
  theRect.top = inRect.origin.y;
  theRect.bottom = ceilf(inRect.origin.y + inRect.size.height);
  return theRect;
}

/// Align rectangles
//
//  Args:
//    alignee - rect to be aligned
//    aligner - rect to be aligned to
//    alignment - alignment to be applied to alignee based on aligner

NSRect GTMAlignRectangles(NSRect alignee, NSRect aligner, NSImageAlignment alignment) {
  switch (alignment) {
    case NSImageAlignTop:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
      break;
      
    case NSImageAlignTopLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
    break;
    
    case NSImageAlignTopRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
      break;

    case NSImageAlignLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
      
    case NSImageAlignBottomLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y;
      break;

    case NSImageAlignBottom:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y;
      break;

    case NSImageAlignBottomRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y;
      break;
      
    case NSImageAlignRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
      
    default:
    case NSImageAlignCenter:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
  }
  return alignee;
}

NSRect GTMScaleRectangleToSize(NSRect scalee, NSSize size, NSImageScaling scaling) {
  switch (scaling) {
    case NSScaleProportionally: {
      float height = NSHeight(scalee);
      float width = NSWidth(scalee);
      if (isnormal(height) && isnormal(width) && 
          (height > size.height || width > size.width)) {
        float horiz = size.width / width;
        float vert = size.height / height;
        float newScale = horiz < vert ? horiz : vert;
        scalee = GTMNSRectScale(scalee, newScale, newScale);
      }
      break;
    }
      
    case NSScaleToFit:
      scalee.size = size;
      break;
      
    case NSScaleNone:
    default:
      // Do nothing
      break;
  }
  return scalee;
}
