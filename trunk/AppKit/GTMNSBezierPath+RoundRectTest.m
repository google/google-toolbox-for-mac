//
//  NSBezierPath+RoundRectTest.m
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
#import "GTMNSBezierPath+RoundRect.h"
#import "GTMAppKit+UnitTesting.h"

@interface GTMNSBezierPath_RoundRectTest : SenTestCase<GTMUnitTestViewDrawer>
@end

@implementation GTMNSBezierPath_RoundRectTest

- (void)testRoundRects {
  GTMAssertDrawingEqualToFile(self, NSMakeSize(330, 430), 
                              @"GTMNSBezierPath+RoundRectTest", nil, nil);
}

// Draws all of our tests so that we can compare this to our stored TIFF file.
- (void)gtm_unitTestViewDrawRect:(NSRect)rect contextInfo:(void*)contextInfo{
  NSRect theRects[] = { 
    NSMakeRect(0.0f, 10.0f, 0.0f, 0.0f), //Empty Rect test
    NSMakeRect(50.0f, 10.0f, 30.0f, 30.0f), //Square Test
    NSMakeRect(100.0f, 10.0f, 1.0f, 2.0f), //Small Test
    NSMakeRect(120.0f, 10.0f, 15.0f, 20.0f), //Medium Test
    NSMakeRect(140.0f, 10.0f, 150.0f, 30.0f)  //Large Test
  };
  const unsigned int theRectCount = sizeof(theRects) / sizeof(NSRect);
  
  // Line Width Tests
  float theLineWidths[] = { 0.5f, 50.0f, 2.0f };
  const unsigned int theLineWidthCount = sizeof(theLineWidths) / sizeof(float);
  unsigned int i,j;
  
  for (i = 0; i < theLineWidthCount; ++i) {
    for (j = 0; j < theRectCount; ++j) {
      NSBezierPath *roundRect = [NSBezierPath gtm_bezierPathWithRoundRect:theRects[j] 
                                                             cornerRadius:20.0f];
      [roundRect setLineWidth: theLineWidths[i]];
      [roundRect stroke];
      float newWidth = 35.0f;
      if (i < theLineWidthCount - 1) {
        newWidth += theLineWidths[i + 1] + theLineWidths[i];
      }
      theRects[j].origin.y += newWidth;
    }
  }
  
  // Fill test
  NSColor *theColors[] = { 
    [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:1.0f], 
    [NSColor colorWithCalibratedRed:0.2f green:0.4f blue:0.6f alpha:0.4f]
  };
  const unsigned int theColorCount = sizeof(theColors)/sizeof(NSColor);
  
  for (i = 0; i < theColorCount; ++i) {
    for (j = 0; j < theRectCount; ++j) {
      NSBezierPath *roundRect = [NSBezierPath gtm_bezierPathWithRoundRect:theRects[j] 
                                                             cornerRadius:10.0f];
      [theColors[i] setFill];
      [roundRect fill];
      theRects[j].origin.y += 35.0f;
    }
  }
  
  // Flatness test
  float theFlatness[] = {0.0f, 0.1f, 1.0f, 10.0f};
  const unsigned int theFlatnessCount = sizeof(theFlatness)/sizeof(float);
  
  for (i = 0; i < theFlatnessCount; i++) {
    for (j = 0; j < theRectCount; ++j) {
      NSBezierPath *roundRect = [NSBezierPath gtm_bezierPathWithRoundRect:theRects[j] 
                                                             cornerRadius:6.0f];
      [roundRect setFlatness:theFlatness[i]];
      [roundRect stroke];
      theRects[j].origin.y += 35.0f;
    }
  }  
}


@end
