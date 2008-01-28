//
//  GTMNSBezierPath+CGPathTest.m
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

#import <Cocoa/Cocoa.h>

#import <SenTestingKit/SenTestingKit.h>
#import "GTMNSBezierPath+CGPath.h"
#import "GTMNSView+UnitTesting.h"

@interface GTMNSBezierPath_CGPathTest : SenTestCase<GTMUnitTestViewDrawer>
@end

@implementation GTMNSBezierPath_CGPathTest

- (void)testCreateCGPath {
  GTMAssertDrawingEqualToFile(self, NSMakeSize(100, 100), @"GTMNSBezierPath+CGPathTest", nil, nil);
}


// Draws all of our tests so that we can compare this to our stored TIFF file.
- (void)unitTestViewDrawRect:(NSRect)rect contextInfo:(void*)contextInfo{
  NSBezierPath *thePath = [NSBezierPath bezierPath];
  NSPoint theStart = NSMakePoint(20.0f, 20.0f);
  
  // Test moveto/lineto
  [thePath moveToPoint: theStart];
  for (unsigned int i = 0; i < 10; ++i) {
    NSPoint theNewPoint = NSMakePoint(i * 5, i * 10);
    [thePath lineToPoint: theNewPoint];
    theNewPoint = NSMakePoint(i * 2, i * 6);
    [thePath moveToPoint: theNewPoint];
  }
  
  // Test moveto/curveto
  for (unsigned int i = 0; i < 10;  ++i) {
    NSPoint startPoint = NSMakePoint(5.0f, 50.0f);
    NSPoint endPoint = NSMakePoint(55.0f, 50.0f);
    NSPoint controlPoint1 = NSMakePoint(17.5f, 50.0f + 5.0f * i);
    NSPoint controlPoint2 = NSMakePoint(42.5f, 50.0f - 5.0f * i);
    [thePath moveToPoint:startPoint];
    [thePath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
  }
  // test close
  [thePath closePath];
  
  CGPathRef cgPath = [thePath gtm_createCGPath];
  if (nil == cgPath) {
    @throw [NSException failureInFile:[NSString stringWithCString:__FILE__] 
                               atLine:__LINE__
                      withDescription:@"Nil CGPath"];
  }
  CGContextRef cgContext = [[NSGraphicsContext currentContext] graphicsPort];
  if (nil == cgContext) {
    @throw [NSException failureInFile:[NSString stringWithCString:__FILE__] 
                               atLine:__LINE__
                      withDescription:@"Nil CGContext"];
  }
  CGContextAddPath(cgContext, cgPath);
  CGContextStrokePath(cgContext);
  CGPathRelease(cgPath);
}

@end
