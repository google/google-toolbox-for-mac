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

#import <SenTestingKit/SenTestingKit.h>
#import "GTMGeometryUtils.h"

@interface GTMGeometryUtilsTest : SenTestCase
@end

@implementation GTMGeometryUtilsTest

- (void)testGTMGetMainDisplayHeight {
  STAssertTrue(CGRectGetHeight(CGDisplayBounds(CGMainDisplayID())) == GTMGetMainDisplayHeight(), nil);
}


- (void)testGTMGlobalHIPointToNSPoint {
  HIPoint hiPoint = CGPointMake(12.5,14.5);
  NSPoint nsPoint = GTMGlobalHIPointToNSPoint(hiPoint);
  STAssertTrue(nsPoint.x == hiPoint.x && 
               nsPoint.y == GTMGetMainDisplayHeight() - hiPoint.y, nil);
}


- (void)testGTMGlobalNSPointToHIPoint {
  NSPoint nsPoint = NSMakePoint(12.5,14.5);
  HIPoint hiPoint = GTMGlobalNSPointToHIPoint(nsPoint);
  STAssertTrue(nsPoint.x == hiPoint.x && 
               nsPoint.y == GTMGetMainDisplayHeight() - hiPoint.y, nil);    
}


- (void)testGTMGlobalCGPointToNSPoint {
  CGPoint cgPoint = CGPointMake(15.1,6.2);
  NSPoint nsPoint = GTMCGPointToNSPoint(cgPoint);
  STAssertTrue(CGPointEqualToPoint(*(CGPoint*)&nsPoint, cgPoint), nil);
               
}


- (void)testGTMGlobalNSPointToCGPoint {
  NSPoint nsPoint = NSMakePoint(10.2,1.5);
  CGPoint cgPoint = GTMNSPointToCGPoint(nsPoint);
  STAssertTrue(CGPointEqualToPoint(cgPoint, *(CGPoint*)&nsPoint), nil);
}


- (void)testGTMGlobalCGPointToHIPoint {
  CGPoint cgPoint = CGPointMake(12.5,14.5);
  HIPoint hiPoint = GTMGlobalCGPointToHIPoint(cgPoint);
  STAssertTrue(cgPoint.x == hiPoint.x && 
               cgPoint.y == GTMGetMainDisplayHeight() - hiPoint.y, nil);  
}


- (void)testGTMGlobalHIPointToCGPoint {
  HIPoint hiPoint = CGPointMake(12.5,14.5);
  CGPoint cgPoint = GTMGlobalHIPointToCGPoint(hiPoint);
  STAssertTrue(cgPoint.x == hiPoint.x && 
               cgPoint.y == GTMGetMainDisplayHeight() - hiPoint.y, nil);  
}


- (void)testGTMGlobalNSRectToHIRect {
  NSRect nsRect = NSMakeRect(40,16,17,18);
  HIRect hiRect = GTMGlobalNSRectToHIRect(nsRect);
  STAssertTrue(nsRect.origin.x == hiRect.origin.x && 
               nsRect.origin.y == GTMGetMainDisplayHeight() - hiRect.origin.y - hiRect.size.height &&
               nsRect.size.height == hiRect.size.height &&
               nsRect.size.width == hiRect.size.width, nil);  
}


- (void)testGTMGlobalCGRectToHIRect {
  CGRect cgRect = CGRectMake(40,16,17,19.0);
  HIRect hiRect = GTMGlobalCGRectToHIRect(cgRect);
  STAssertTrue(cgRect.origin.x == hiRect.origin.x && 
               cgRect.origin.y == GTMGetMainDisplayHeight() - hiRect.origin.y - hiRect.size.height &&
               cgRect.size.height == hiRect.size.height &&
               cgRect.size.width == hiRect.size.width, nil);  
}


- (void)testGTMGlobalHIRectToNSRect {
  HIRect hiRect = CGRectMake(40.2,16.3,17.2,18.9);
  NSRect nsRect = GTMGlobalHIRectToNSRect(hiRect);
  STAssertTrue(nsRect.origin.x == hiRect.origin.x && 
               nsRect.origin.y == GTMGetMainDisplayHeight() - hiRect.origin.y - hiRect.size.height &&
               nsRect.size.height == hiRect.size.height &&
               nsRect.size.width == hiRect.size.width, nil);      
}


- (void)testGTMGlobalCGRectToNSRect {
  CGRect cgRect = CGRectMake(1.5,2.4,10.6,11.7);
  NSRect nsRect = GTMCGRectToNSRect(cgRect);
  STAssertTrue(CGRectEqualToRect(cgRect, *(CGRect*)&nsRect), nil);
}


- (void)testGTMGlobalNSRectToCGRect {
  NSRect nsRect = NSMakeRect(4.6,3.2,22.1,45.0);
  CGRect cgRect = GTMNSRectToCGRect(nsRect);
  STAssertTrue(CGRectEqualToRect(cgRect, *(CGRect*)&nsRect), nil);
}


- (void)testGTMGlobalHIRectToCGRect {
  HIRect hiRect = CGRectMake(40.2,16.3,17.2,18.9);
  CGRect cgRect = GTMGlobalHIRectToCGRect(hiRect);
  STAssertTrue(cgRect.origin.x == hiRect.origin.x && 
               cgRect.origin.y == GTMGetMainDisplayHeight() - hiRect.origin.y - hiRect.size.height &&
               cgRect.size.height == hiRect.size.height &&
               cgRect.size.width == hiRect.size.width, nil);    
}


- (void)testGTMGlobalRectToNSRect {
  Rect rect = { 10,50,40,60 };
  NSRect nsRect = GTMGlobalRectToNSRect(rect);
  HIRect hiRect1 = GTMRectToHIRect(rect);
  HIRect hiRect2 = GTMGlobalNSRectToHIRect(nsRect);
  STAssertTrue(CGRectEqualToRect(hiRect1,hiRect2), nil);
}


- (void)testGTMGlobalNSRectToRect {
  NSRect nsRect = NSMakeRect(1.5,2.4,10.6,11.7);
  HIRect hiRect = GTMGlobalNSRectToHIRect(nsRect);
  Rect rect1 = GTMGlobalNSRectToRect(nsRect);
  Rect rect2 = GTMHIRectToRect(hiRect);
  STAssertTrue(rect1.left == rect2.left &&
               rect1.right == rect2.right &&
               rect1.top == rect2.top &&
               rect1.bottom == rect2.bottom, nil);   
}


- (void)testGTMGlobalRectToHIRect {
  Rect rect = { 10,20,30,40 };
  HIRect hiRect = GTMRectToHIRect(rect);
  STAssertTrue(CGRectEqualToRect(hiRect, CGRectMake(20,10,20,20)), nil);  
}


- (void)testGTMGlobalHIRectToRect {
  HIRect hiRect = CGRectMake(1.5,2.4,10.6,11.7);
  Rect rect = GTMHIRectToRect(hiRect);
  STAssertTrue(rect.left == 1 &&
               rect.right == 13 &&
               rect.top == 2 &&
               rect.bottom == 15, nil);    
}


- (void)testGTMGlobalCGRectToRect { 
  CGRect cgRect = CGRectMake(1.5,2.4,10.6,11.7);
  HIRect hiRect = GTMGlobalCGRectToHIRect(cgRect);
  Rect rect1 = GTMGlobalCGRectToRect(cgRect);
  Rect rect2 = GTMHIRectToRect(hiRect);
  STAssertTrue(rect1.left == rect2.left &&
               rect1.right == rect2.right &&
               rect1.top == rect2.top &&
               rect1.bottom == rect2.bottom, nil); 
}


- (void)testGTMGlobalRectToCGRect {
  Rect rect = { 10,50,40,60 };
  CGRect nsRect = GTMGlobalRectToCGRect(rect);
  HIRect hiRect1 = GTMRectToHIRect(rect);
  HIRect hiRect2 = GTMGlobalCGRectToHIRect(nsRect);
  STAssertTrue(CGRectEqualToRect(hiRect1,hiRect2), nil);
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
    NSImageAlignment alignment;
  } TestData;
  
  TestData data[] = {
    { {1,2}, NSImageAlignTop },
    { {0,2}, NSImageAlignTopLeft },
    { {2,2}, NSImageAlignTopRight },
    { {0,1}, NSImageAlignLeft },
    { {1,0}, NSImageAlignBottom },
    { {0,0}, NSImageAlignBottomLeft },
    { {2,0}, NSImageAlignBottomRight },
    { {2,1}, NSImageAlignRight },
    { {1,1}, NSImageAlignCenter },
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
                                           NSScaleProportionally);
    STAssertEquals(result, GTMNSRectOfSize(tests[i].newSize_), @"failed on test %z", i);
  }
  
  NSRect result = GTMScaleRectangleToSize(NSZeroRect, tests[0].size_,
                                         NSScaleProportionally);
  STAssertEquals(result, NSZeroRect, nil);
  
  result = GTMScaleRectangleToSize(rect, tests[0].size_,
                                  NSScaleToFit);
  STAssertEquals(result, GTMNSRectOfSize(tests[0].size_), nil);
  
  result = GTMScaleRectangleToSize(rect, tests[0].size_,
                                  NSScaleNone);
  STAssertEquals(result, rect, nil);

}
@end
