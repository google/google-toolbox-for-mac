//
//  GTMLinearRGBShading.m
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

#import "GTMLinearRGBShading.h"

// Carbon callback function required for CoreGraphics
static void cShadeFunction(void *info, const float *inPos, float *outVals);

@implementation GTMLinearRGBShading
+ (id)shadingFromColor:(NSColor *)begin toColor:(NSColor *)end 
        fromSpaceNamed:(NSString*)colorSpaceName {
  NSColor *theColors[] = { begin, end };
  float thePositions[] = { 0.0f, 1.0f };
  return [[self class] shadingWithColors:theColors
                          fromSpaceNamed:colorSpaceName
                            atPositions:thePositions
                                  count:(sizeof(thePositions)/sizeof(float))];
}

+ (id)shadingWithColors:(NSColor **)colors fromSpaceNamed:(NSString*)colorSpaceName
            atPositions:(float *)positions count:(unsigned)count {

  GTMLinearRGBShading *theShading = [[[[self class] alloc] initWithColorSpaceName:colorSpaceName] autorelease];
  for (unsigned int i = 0; i < count; ++i) {
    [theShading insertStop:colors[i] atPosition:positions[i]];
  }
  return theShading;
}

- (id)initWithColorSpaceName:(NSString*)colorSpaceName {
  if ((self = [super init])) {
    if ([colorSpaceName isEqualToString:NSDeviceRGBColorSpace]) {
      isCalibrated_ = NO;
    } else if ([colorSpaceName isEqualToString:NSCalibratedRGBColorSpace]) {
      isCalibrated_ = YES;
    }
    else {
      [self dealloc];
      self = nil;
    }
  }
  return self;
}

- (void) dealloc {
  if (nil != function_) {
    CGFunctionRelease(function_);
  }
  if (nil != colorSpace_) {
    CGColorSpaceRelease(colorSpace_);
  }
  [super dealloc];
}


- (void)insertStop:(id)item atPosition:(float)position {
  NSString *colorSpaceName = isCalibrated_ ? NSCalibratedRGBColorSpace : NSDeviceRGBColorSpace;
  NSColor *tempColor = [item colorUsingColorSpaceName: colorSpaceName];
  if (nil != tempColor) {
    [super insertStop:tempColor atPosition:position];
  }
}

//  Calculate a linear value based on our stops
- (id)valueAtPosition:(float)position {
  unsigned int index = 0;
  unsigned int colorCount = [self stopCount];
  float stop1Position = 0.0f;
  NSColor *stop1Color = [self stopAtIndex:index position:&stop1Position];
  index += 1;
  float stop2Position = 0.0f;
  NSColor *stop2Color = nil;
  NSColor *theColor = nil;
  if (colorCount > 1) {
    stop2Color = [self stopAtIndex:index position:&stop2Position];
    index += 1;
  } else {
    // if we only have one value, that's what we return
    stop2Position = stop1Position;
    stop2Color = stop1Color;
  }

  while (index < colorCount && stop2Position < position) {
    stop1Color = stop2Color;
    stop1Position = stop2Position;
    stop2Color = [self stopAtIndex:index position:&stop2Position];
    index += 1;
  }

  if (position <= stop1Position) {
    // if we are less than our lowest position, return our first color
    theColor = stop1Color;
    [stop1Color getRed:&colorValue[0] green:&colorValue[1] 
                  blue:&colorValue[2] alpha:&colorValue[3]];
  } else if (position >= stop2Position) {
    // likewise if we are greater than our highest position, return the last color
    [stop2Color getRed:&colorValue[0] green:&colorValue[1] 
                  blue:&colorValue[2] alpha:&colorValue[3]];
  } else {
    // otherwise interpolate between the two
    position = (position - stop1Position) / (stop2Position - stop1Position);
    float red1, red2, green1, green2, blue1, blue2, alpha1, alpha2;
    [stop1Color getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [stop2Color getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    colorValue[0] = (red2 - red1) * position + red1;
    colorValue[1] = (green2 - green1) * position + green1;
    colorValue[2] = (blue2 - blue1) * position + blue1;
    colorValue[3] = (alpha2 - alpha1) * position + alpha1;
  }
  
  // Yes, I am casting a float[] to an id to pass it by the compiler. This
  // significantly improves performance though as I avoid creating an NSColor
  // for every scanline which later has to be cleaned up in an autorelease pool
  // somewhere. Causes guardmalloc to run significantly faster.
  return (id)colorValue;
}

//
//  switch from C to obj-C. The callback to a shader is a c function
//  but we want to call our objective c object to do all the
//  calculations for us. We have passed our function our
//  GTMLinearRGBShading as an obj-c object in the |info| so
//  we just turn around and ask it to calculate our value based
//  on |inPos| and then stick the results back in |outVals|
//
//   Args: 
//    info: is the GTMLinearRGBShading as an
//          obj-C object. 
//    inPos: the position to calculate values for. This is a pointer to
//           a single float value
//    outVals: where we store our return values. Since we are calculating
//             an RGBA color, this is a pointer to an array of four float values
//             ranging from 0.0f to 1.0f
//      
//
static void cShadeFunction(void *info, const float *inPos, float *outVals) {
  id object = (id)info;
  float *colorValue = (float*)[object valueAtPosition:*inPos];
  outVals[0] = colorValue[0];
  outVals[1] = colorValue[1];
  outVals[2] = colorValue[2];
  outVals[3] = colorValue[3];
}

- (CGFunctionRef) shadeFunction {
  // lazily create the function as necessary
  if (nil == function_) {
    // We have to go to carbon here, and create the CGFunction. Note that this
    // diposed if necessary in the dealloc call.
    const CGFunctionCallbacks shadeFunctionCallbacks = { 0, &cShadeFunction, NULL };
    
    // TODO: (dmaclach): this code assumes that we have a range from 0.0f to 1.0f
    // which may not be true according to the stops that the user has given us.
    // In general you have stops at 0.0 and 1.0, so this will do for right now
    // but may be an issue in the future.
    const float inRange[2] = { 0.0f, 1.0f };	
    const float outRange[8] = { 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f };
    function_ = CGFunctionCreate(self,				
                                  sizeof(inRange) / (sizeof(float) * 2), inRange,			
                                  sizeof(outRange) / (sizeof(float) * 2), outRange,		
                                  &shadeFunctionCallbacks);
  }
  return function_;
}  

- (CGColorSpaceRef)colorSpace {
  // lazily create the colorspace as necessary
  if (nil == colorSpace_) {
    if (isCalibrated_) {
      colorSpace_ = CGColorSpaceCreateWithName(kCGColorSpaceUserRGB);
    } else {
      colorSpace_ = CGColorSpaceCreateDeviceRGB(); 
    }
  } 
  return colorSpace_;
}
@end
