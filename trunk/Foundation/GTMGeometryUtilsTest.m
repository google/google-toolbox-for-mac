//
//  GTMGeometryUtilsTest.m
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

#import "GTMSenTestCase.h"
#import "GTMGeometryUtils.h"

@interface GTMGeometryUtilsTest : SenTestCase
@end

@implementation GTMGeometryUtilsTest

- (void)testGTMCGPointToNSPoint {
  CGPoint cgPoint = CGPointMake(15.1,6.2);
  NSPoint nsPoint = GTMCGPointToNSPoint(cgPoint);
  STAssertTrue(CGPointEqualToPoint(*(CGPoint*)&nsPoint, cgPoint), nil);
}

- (void)testGTMNSPointToCGPoint {
  NSPoint nsPoint = NSMakePoint(10.2,1.5);
  CGPoint cgPoint = GTMNSPointToCGPoint(nsPoint);
  STAssertTrue(CGPointEqualToPoint(cgPoint, *(CGPoint*)&nsPoint), nil);
}

- (void)testGTMCGRectToNSRect {
  CGRect cgRect = CGRectMake(1.5,2.4,10.6,11.7);
  NSRect nsRect = GTMCGRectToNSRect(cgRect);
  STAssertTrue(CGRectEqualToRect(cgRect, *(CGRect*)&nsRect), nil);
}


- (void)testGTMNSRectToCGRect {
  NSRect nsRect = NSMakeRect(4.6,3.2,22.1,45.0);
  CGRect cgRect = GTMNSRectToCGRect(nsRect);
  STAssertTrue(CGRectEqualToRect(cgRect, *(CGRect*)&nsRect), nil);
}

- (void)testGTMCGSizeToNSSize {
  CGSize cgSize = {5,6};
  NSSize nsSize = GTMCGSizeToNSSize(cgSize);
  STAssertTrue(CGSizeEqualToSize(cgSize, *(CGSize*)&nsSize), nil);
}

- (void)testGTMNSSizeToCGSize {
  NSSize nsSize = {22,15};
  CGSize cgSize = GTMNSSizeToCGSize(nsSize);
  STAssertTrue(CGSizeEqualToSize(cgSize, *(CGSize*)&nsSize), nil);
}

- (void)testGTMDistanceBetweenPoints {
  NSPoint pt1 = NSMakePoint(0, 0);
  NSPoint pt2 = NSMakePoint(3, 4);
  STAssertEquals(GTMDistanceBetweenPoints(pt1, pt2), 5.0f, nil);
  STAssertEquals(GTMDistanceBetweenPoints(pt2, pt1), 5.0f, nil);
  pt1 = NSMakePoint(1, 1);
  pt2 = NSMakePoint(1, 1);
  STAssertEquals(GTMDistanceBetweenPoints(pt1, pt2), 0.0f, nil);
}

- (void)testGTMAlignRectangles {
  typedef struct  {
    NSPoint expectedOrigin;
    GTMRectAlignment alignment;
  } TestData;
  
  TestData data[] = {
    { {1,2}, GTMRectAlignTop },
    { {0,2}, GTMRectAlignTopLeft },
    { {2,2}, GTMRectAlignTopRight },
    { {0,1}, GTMRectAlignLeft },
    { {1,0}, GTMRectAlignBottom },
    { {0,0}, GTMRectAlignBottomLeft },
    { {2,0}, GTMRectAlignBottomRight },
    { {2,1}, GTMRectAlignRight },
    { {1,1}, GTMRectAlignCenter },
  };
    
  NSRect rect1 = NSMakeRect(0, 0, 4, 4);
  NSRect rect2 = NSMakeRect(0, 0, 2, 2);
  
  for (int i = 0; i < sizeof(data) / sizeof(TestData); i++) {
    NSRect expectedRect;
    expectedRect.origin = data[i].expectedOrigin;
    expectedRect.size = NSMakeSize(2, 2);
    NSRect outRect = GTMAlignRectangles(rect2, rect1, data[i].alignment);
    STAssertEquals(outRect, expectedRect, nil);
  }
}

- (void)testGTMPointsOnRect {
  NSRect rect = NSMakeRect(0, 0, 2, 2);
  CGRect cgRect = GTMNSRectToCGRect(rect);
  
  NSPoint point = GTMNSMidLeft(rect);
  CGPoint cgPoint = GTMCGMidLeft(cgRect);
  STAssertEquals(point.x, cgPoint.x, nil);
  STAssertEquals(point.y, cgPoint.y, nil);
  STAssertEqualsWithAccuracy(point.y, 1.0f, 0.01f, nil);
  STAssertEqualsWithAccuracy(point.x, 0.0f, 0.01f, nil);

  point = GTMNSMidRight(rect);
  cgPoint = GTMCGMidRight(cgRect);
  STAssertEquals(point.x, cgPoint.x, nil);
  STAssertEquals(point.y, cgPoint.y, nil);
  STAssertEqualsWithAccuracy(point.y, 1.0f, 0.01f, nil);
  STAssertEqualsWithAccuracy(point.x, 2.0f, 0.01f, nil);

  point = GTMNSMidTop(rect);
  cgPoint = GTMCGMidTop(cgRect);
  STAssertEquals(point.x, cgPoint.x, nil);
  STAssertEquals(point.y, cgPoint.y, nil);
  STAssertEqualsWithAccuracy(point.y, 2.0f, 0.01f, nil);
  STAssertEqualsWithAccuracy(point.x, 1.0f, 0.01f, nil);
  
  point = GTMNSMidBottom(rect);
  cgPoint = GTMCGMidBottom(cgRect);
  STAssertEquals(point.x, cgPoint.x, nil);
  STAssertEquals(point.y, cgPoint.y, nil);
  STAssertEqualsWithAccuracy(point.y, 0.0f, 0.01f, nil);
  STAssertEqualsWithAccuracy(point.x, 1.0f, 0.01f, nil);
}

- (void)testGTMRectScaling {
  NSRect rect = NSMakeRect(1.0f, 2.0f, 5.0f, 10.0f);
  NSRect rect2 = NSMakeRect(1.0f, 2.0f, 1.0f, 12.0f);
  STAssertEquals(GTMNSRectScale(rect, 0.2f, 1.2f), 
                 rect2, nil);
  STAssertEquals(GTMCGRectScale(GTMNSRectToCGRect(rect), 0.2f, 1.2f), 
                 GTMNSRectToCGRect(rect2), nil);
}
  
- (void)testGTMScaleRectangleToSize {
  NSRect rect = NSMakeRect(0.0f, 0.0f, 10.0f, 10.0f);
  typedef struct {
    NSSize size_;
    NSSize newSize_;
  } Test;
  Test tests[] = {
    { { 5.0, 10.0 }, { 5.0, 5.0 } },
    { { 10.0, 5.0 }, { 5.0, 5.0 } },
    { { 10.0, 10.0 }, { 10.0, 10.0 } },
    { { 11.0, 11.0, }, { 10.0, 10.0 } },
    { { 5.0, 2.0 }, { 2.0, 2.0 } },
    { { 2.0, 5.0 }, { 2.0, 2.0 } },
    { { 2.0, 2.0 }, { 2.0, 2.0 } },
    { { 0.0, 10.0 }, { 0.0, 0.0 } }
  };
  
  for (size_t i = 0; i < sizeof(tests) / sizeof(Test); ++i) {
    NSRect result = GTMScaleRectangleToSize(rect, tests[i].size_,
                                            GTMScaleProportionally);
    STAssertEquals(result, GTMNSRectOfSize(tests[i].newSize_), @"failed on test %z", i);
  }
  
  NSRect result = GTMScaleRectangleToSize(NSZeroRect, tests[0].size_,
                                          GTMScaleProportionally);
  STAssertEquals(result, NSZeroRect, nil);
  
  result = GTMScaleRectangleToSize(rect, tests[0].size_,
                                   GTMScaleToFit);
  STAssertEquals(result, GTMNSRectOfSize(tests[0].size_), nil);
  
  result = GTMScaleRectangleToSize(rect, tests[0].size_,
                                   GTMScaleNone);
  STAssertEquals(result, rect, nil);
}
@end
