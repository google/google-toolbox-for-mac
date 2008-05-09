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

/// Align rectangles
//
//  Args:
//    alignee - rect to be aligned
//    aligner - rect to be aligned to
//    alignment - alignment to be applied to alignee based on aligner

NSRect GTMAlignRectangles(NSRect alignee, NSRect aligner, GTMRectAlignment alignment) {
  switch (alignment) {
    case GTMRectAlignTop:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
      break;
      
    case GTMRectAlignTopLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
    break;
    
    case GTMRectAlignTopRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y + NSHeight(aligner) - NSHeight(alignee);
      break;

    case GTMRectAlignLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
      
    case GTMRectAlignBottomLeft:
      alignee.origin.x = aligner.origin.x;
      alignee.origin.y = aligner.origin.y;
      break;

    case GTMRectAlignBottom:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y;
      break;

    case GTMRectAlignBottomRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y;
      break;
      
    case GTMRectAlignRight:
      alignee.origin.x = aligner.origin.x + NSWidth(aligner) - NSWidth(alignee);
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
      
    default:
    case GTMRectAlignCenter:
      alignee.origin.x = aligner.origin.x + (NSWidth(aligner) * .5f - NSWidth(alignee) * .5f);
      alignee.origin.y = aligner.origin.y + (NSHeight(aligner) * .5f - NSHeight(alignee) * .5f);
      break;
  }
  return alignee;
}

NSRect GTMScaleRectangleToSize(NSRect scalee, NSSize size, GTMScaling scaling) {
  switch (scaling) {
    case GTMScaleProportionally: {
      CGFloat height = NSHeight(scalee);
      CGFloat width = NSWidth(scalee);
      if (isnormal(height) && isnormal(width) && 
          (height > size.height || width > size.width)) {
        CGFloat horiz = size.width / width;
        CGFloat vert = size.height / height;
        CGFloat newScale = horiz < vert ? horiz : vert;
        scalee = GTMNSRectScale(scalee, newScale, newScale);
      }
      break;
    }
      
    case GTMScaleToFit:
      scalee.size = size;
      break;
      
    case GTMScaleNone:
    default:
      // Do nothing
      break;
  }
  return scalee;
}
