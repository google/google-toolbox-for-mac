//
//  GTMRoundedRectPath.m
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
#include "GTMRoundedRectPath.h"

CGPathRef GTMCreateRoundedRectPath(CGRect rect, CGFloat radius) {
  CGMutablePathRef path = CGPathCreateMutable();

  CGPoint topLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
  CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
  CGPoint bottomLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));

  CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPathAddArcToPoint(path, NULL,
                      topLeft.x, topLeft.y,
                      bottomLeft.x, bottomLeft.y,
                      radius);
  CGPathAddArcToPoint(path, NULL,
                      bottomLeft.x, bottomLeft.y,
                      bottomRight.x, bottomRight.y,
                      radius);
  CGPathAddArcToPoint(path, NULL,
                      bottomRight.x, bottomRight.y,
                      topRight.x, topRight.y,
                      radius);
  CGPathAddArcToPoint(path, NULL,
                      topRight.x, topRight.y,
                      topLeft.x, topLeft.y,
                      radius);
  CGPathCloseSubpath(path);

  CGPathRef immutablePath = CGPathCreateCopy(path);
  CGPathRelease(path);
  return immutablePath;
}
