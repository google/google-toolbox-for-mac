//
//  NSColor+ThemeTest.m
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
#import "GTMNSColor+Theme.h"
#import "GTMNSWorkspace+Theme.h"
#import "GTMSystemVersion.h"


@interface GTMNSColor_ThemeTest : SenTestCase 
@end

@implementation GTMNSColor_ThemeTest

//METHOD_CHECK(NSWorkspace, themeAppearance);

// utility function for giving random floats between 0.0f and 1.0f
static float Randomf() {
  float val = random();
  return val / INT32_MAX;
}

- (void)testColorWithThemeTextColor {
  float colorValues[][4] = {
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 0.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.449989, 0.449989, 0.449989, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.449989, 0.449989, 0.449989, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.599985, 0.599985, 0.599985, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.599985, 0.599985, 0.599985, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.499992, 0.499992, 0.499992, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 }
  };
	
	if ([GTMSystemVersion isLeopardOrGreater]) {
		// kThemeTextColorRootMenuDisabled changed to white in Leopard.
		colorValues[35][0] = 1.0;
		colorValues[35][1] = 1.0;
		colorValues[35][2] = 1.0;
	}
  for(int i = kThemeTextColorWhite; i < kThemeTextColorSystemDetail; i++) {
    if (i == 0) continue;
    NSColor *textColor = [NSColor gtm_colorWithThemeTextColor:i];
    float nsComponents[5];
    [textColor getComponents: nsComponents];
    for(int j = 0; j < 4; j++) {
      STAssertEqualsWithAccuracy(nsComponents[j], colorValues[i + 2][j], 0.000001,
                   @"Theme Text Color %d is wrong", i);
      STAssertEqualObjects([textColor colorSpaceName], NSDeviceRGBColorSpace,
                           @"Color space must be DeviceRGB");
    }
  }
}

- (void)testColorWithThemeBrushColor {
  float colorValues[][4] = {
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 0.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.980011, 0.990005, 0.990005, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.709789, 0.835294, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.492195, 0.675792, 0.847669, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.000000, 0.000000, 0.000000, 1.000000 },
    { 0.500008, 0.500008, 0.500008, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.600000, 0.600000, 0.600000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.510002, 0.510002, 0.510002, 1.000000 },
    { 0.760006, 0.760006, 0.760006, 1.000000 },
    { 0.940002, 0.940002, 0.940002, 1.000000 },
    { 0.980011, 0.980011, 0.980011, 1.000000 },
    { 0.670008, 0.670008, 0.670008, 1.000000 },
    { 0.860014, 0.860014, 0.860014, 1.000000 },
    { 0.880003, 0.880003, 0.880003, 1.000000 },
    { 0.880003, 0.880003, 0.880003, 1.000000 },
    { 0.990005, 0.990005, 0.990005, 1.000000 },
    { 0.900008, 0.900008, 0.900008, 1.000000 },
    { 0.930007, 0.930007, 0.930007, 1.000000 },
    { 0.930007, 0.930007, 0.930007, 1.000000 },
    { 0.990005, 0.990005, 0.990005, 1.000000 },
    { 0.540002, 0.540002, 0.540002, 1.000000 },
    { 0.590005, 0.590005, 0.590005, 1.000000 },
    { 0.590005, 0.590005, 0.590005, 1.000000 },
    { 0.730007, 0.730007, 0.730007, 1.000000 },
    { 0.640009, 0.640009, 0.640009, 1.000000 },
    { 0.640009, 0.640009, 0.640009, 1.000000 },
    { 0.820005, 0.820005, 0.820005, 1.000000 },
    { 0.820005, 0.820005, 0.820005, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 1.000000, 1.000000, 1.000000, 1.000000 },
    { 0.925490, 0.952895, 0.996094, 1.000000 }
  };
  
  NSString *theme = [[NSWorkspace sharedWorkspace] gtm_themeAppearance];
  if ([theme isEqualToString:(NSString*)kThemeAppearanceAquaGraphite]) {
    // These are the only two brushes that change with an appearance change
    colorValues[21][0] = 0.605478;
    colorValues[21][1] = 0.667979;
    colorValues[21][2] = 0.738293;
    colorValues[59][0] = 0.941192;
    colorValues[59][1] = 0.941192;
    colorValues[59][2] = 0.941192;
  }
  for(int i = kThemeBrushWhite; i < kThemeBrushListViewColumnDivider; i++) {
    // Brush "14" is the selection, so it will change depending on the system
    // There is no brush 0.
    if (i == 0 || i == 14) continue;
    NSColor *brushColor = [NSColor gtm_colorWithThemeBrush:i];
    float nsComponents[5];
    [brushColor getComponents: nsComponents];
    for(int j = 0; j < 4; j++) {
      STAssertEqualsWithAccuracy(nsComponents[j], colorValues[i + 2][j], 0.000001,
                                 @"Theme Text Brush %d is wrong", i + 2);
      STAssertEqualObjects([brushColor colorSpaceName], NSDeviceRGBColorSpace,
                           @"Color space must be DeviceRGB");
    }
  }
}

- (void)testSafeColorWithAlphaComponent {
  NSColorSpace *testSpace[6];
  testSpace[0] = [NSColorSpace genericRGBColorSpace];
  testSpace[1] = [NSColorSpace genericGrayColorSpace];
  testSpace[2] = [NSColorSpace genericCMYKColorSpace];
  testSpace[3] = [NSColorSpace deviceRGBColorSpace];
  testSpace[4] = [NSColorSpace deviceGrayColorSpace];
  testSpace[5] = [NSColorSpace deviceCMYKColorSpace];
  
  float comp[5];
  for (int i = 0; i < sizeof(comp) / sizeof(float); ++i) {
    comp[i] = Randomf();
  }
  
  float alpha = Randomf();
  for (int i = 0; i < sizeof(testSpace) / sizeof(NSColorSpace*); ++i) {
    int componentCount = [testSpace[i] numberOfColorComponents];
    NSColor *color = [NSColor colorWithColorSpace:testSpace[i]
                                       components:comp
                                            count:componentCount + 1];
    NSColor *alphaColor = [color gtm_safeColorWithAlphaComponent:alpha];
    
    float alphaSwap = comp[componentCount];
    comp[componentCount] = alpha;
    NSColor *testColor = [NSColor colorWithColorSpace:testSpace[i]
                                           components:comp
                                                count:componentCount + 1];
    comp[componentCount] = alphaSwap;
    STAssertEqualObjects(alphaColor, 
                         testColor, 
                         @"Compare failed with components: %f %f %f %f %f %f alpha: %f",
                         testSpace[0], testSpace[1], testSpace[2],
                         testSpace[3], testSpace[4], testSpace[5],
                         alpha);
  }
}

- (void)testSafeColorUsingColorSpaceName {

  NSColor *brushColor = [[NSColor selectedMenuItemColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
  STAssertNil(brushColor, @"This doesn't work on Tiger or Leopard");
  
  brushColor = [[NSColor selectedMenuItemColor] gtm_safeColorUsingColorSpaceName:NSDeviceRGBColorSpace];
  STAssertNotNil(brushColor, nil);
}
  

@end
