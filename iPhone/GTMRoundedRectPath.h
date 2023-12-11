//
//  GTMRoundedRectPath.h
//
//  Copyright 2010 Google Inc.
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

#import <CoreGraphics/CoreGraphics.h>

#import "GTMDefines.h"

NS_ASSUME_NONNULL_BEGIN

GTM_EXTERN_C_BEGIN

//  Inscribe a round rectangle inside of rectangle |rect| with a corner radius
//  of |radius|
//
//  Args:
//    context: the context to use
//    rect: outer rectangle to inscribe into
//    radius: radius of the corners. |radius| is clamped internally
//            to be no larger than the smaller of half |rect|'s width or height
void GTMCGContextAddRoundRect(CGContextRef context,
                              CGRect rect,
                              CGFloat radius)
  __attribute__((deprecated("This api will be removed in the future as it appears to have no users; if you have need, please report it on the GitHub project immediately.")));


//  Adds a path which is a round rectangle inscribed inside of rectangle |rect|
//  with a corner radius of |radius|
//
//  Args:
//    path: path to add the rounded rectangle to
//       m: matrix modifying the round rect
//    rect: outer rectangle to inscribe into
//    radius: radius of the corners. |radius| is clamped internally
//            to be no larger than the smaller of half |rect|'s width or height
void GTMCGPathAddRoundRect(CGMutablePathRef path,
                           const CGAffineTransform * __nullable m,
                           CGRect rect,
                           CGFloat radius)
  __attribute__((deprecated("This api will be removed in the future as it appears to have no users; if you have need, please report it on the GitHub project immediately.")));

// Allocates a new rounded corner rectangle path.
CGPathRef GTMCreateRoundedRectPath(CGRect rect, CGFloat radius)
   __attribute__((deprecated("Use of the the above apis")));

GTM_EXTERN_C_END

NS_ASSUME_NONNULL_END
