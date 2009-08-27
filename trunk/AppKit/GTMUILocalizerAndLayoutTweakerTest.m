//
//  GTMUILocalizerAndLayoutTweakerTest.m
//
//  Copyright 2009 Google Inc.
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
#import "GTMUILocalizerAndLayoutTweakerTest.h"
#import "GTMNSObject+UnitTesting.h"
#import "GTMUILocalizerAndLayoutTweaker.h"

static NSUInteger gTestPass = 0;

@interface GTMUILocalizerAndLayoutTweakerTest : GTMTestCase
@end

@implementation GTMUILocalizerAndLayoutTweakerTest
- (void)testWindowLocalization {
  // Test with nib 1
  for (gTestPass = 0; gTestPass < 3; ++gTestPass) {
    GTMUILocalizerAndLayoutTweakerTestWindowController *controller =
      [[GTMUILocalizerAndLayoutTweakerTestWindowController alloc]
        initWithWindowNibName:@"GTMUILocalizerAndLayoutTweakerTest1"];
    NSWindow *window = [controller window];
    STAssertNotNil(window, @"Pass %ld", (long)gTestPass);
    NSString *imageName =
      [NSString stringWithFormat:@"GTMUILocalizerAndLayoutTweakerTest1-%ld",
        (long)gTestPass];
    GTMAssertObjectImageEqualToImageNamed(window, imageName,
                                          @"Pass %ld", (long)gTestPass);
    [controller release];
  }
  // Test with nib 2
  for (gTestPass = 0; gTestPass < 3; ++gTestPass) {
    GTMUILocalizerAndLayoutTweakerTestWindowController *controller =
      [[GTMUILocalizerAndLayoutTweakerTestWindowController alloc]
        initWithWindowNibName:@"GTMUILocalizerAndLayoutTweakerTest2"];
    NSWindow *window = [controller window];
    STAssertNotNil(window, @"Pass %ld", (long)gTestPass);
    NSString *imageName =
      [NSString stringWithFormat:@"GTMUILocalizerAndLayoutTweakerTest2-%ld",
        (long)gTestPass];
    GTMAssertObjectImageEqualToImageNamed(window, imageName,
                                          @"Pass %ld", (long)gTestPass);
    [controller release];
  }
}

- (void)testSizeToFitFixedWidthTextField {
  // In the xib, the one field is over sized, the other is undersized, this
  // way we make sure the code handles both condions as there was a bahavior
  // change between the 10.4 and 10.5 SDKs.
  NSString *kTestStrings[] = {
    @"The quick brown fox jumps over the lazy dog.",
    @"The quick brown fox jumps over the lazy dog.  The quick brown fox jumps "
      @"over the lazy dog.  The quick brown fox jumps over the lazy dog.  "
      @"The quick brown fox jumps over the lazy dog.  The quick brown fox "
      @"jumps over the lazy dog.",
    @"The quick brown fox jumps over the lazy dog.\nThe quick brown fox jumps "
      @"over the lazy dog.\nThe quick brown fox jumps over the lazy dog.\n"
      @"The quick brown fox jumps over the lazy dog.\nThe quick brown fox "
      @"jumps over the lazy dog.",
    @"The quick brown fox jumps over the lazy dog.  The quick brown fox jumps "
      @"over the lazy dog.\nThe quick brown fox jumps over the lazy dog.  "
      @"The quick brown fox jumps over the lazy dog.  The quick brown fox "
      @"jumps over the lazy dog.  The quick brown fox jumps over the lazy "
      @"dog.  The quick brown fox jumps over the lazy dog.\n\nThe End.",
  };
  for (size_t lp = 0; lp < (sizeof(kTestStrings) / sizeof(NSString*)); ++lp) {
    GTMUILocalizerAndLayoutTweakerTestWindowController *controller =
      [[GTMUILocalizerAndLayoutTweakerTestWindowController alloc]
        initWithWindowNibName:@"GTMUILocalizerAndLayoutTweakerTest3"];
    NSWindow *window = [controller window];
    STAssertNotNil(window, @"Pass %ld", (long)lp);
    NSTextField *field;
    GTM_FOREACH_OBJECT(field, [[window contentView] subviews]) {
      STAssertTrue([field isMemberOfClass:[NSTextField class]],
                   @"Pass %ld", (long)lp);
      [field setStringValue:kTestStrings[lp]];
      [GTMUILocalizerAndLayoutTweaker sizeToFitFixedWidthTextField:field];
    }
    NSString *imageName =
      [NSString stringWithFormat:@"GTMUILocalizerAndLayoutTweakerTest3-%ld",
       (long)lp];
    GTMAssertObjectImageEqualToImageNamed(window, imageName,
                                          @"Pass %ld", (long)lp);
    [controller release];
  }
}

@end

@implementation GTMUILocalizerAndLayoutTweakerTestWindowController
@end

@implementation GTMUILocalizerAndLayoutTweakerTestLocalizer

- (NSString *)localizedStringForString:(NSString *)string {
  // "[FRAGMENT]:[COUNT]:[COUNT]"
  // String is split, fragment is repeated count times, and spaces are then
  // trimmed.  Gives us strings that don't change for the test, but easy to
  // vary in size.  Which count is used, is controled by |gTestPass| so we
  // can use a nib more then once.
  NSArray *parts = [string componentsSeparatedByString:@":"];
  if ([parts count] > (gTestPass + 1)) {
    NSString *fragment = [parts objectAtIndex:0];
    NSInteger count = [[parts objectAtIndex:gTestPass + 1] intValue];
    if (count) {
      NSMutableString *result =
        [NSMutableString stringWithCapacity:count * [fragment length]];
      while (count--) {
        [result appendString:fragment];
      }
      NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
      return [result stringByTrimmingCharactersInSet:ws];
    }
  }
  return nil;
}

- (void)awakeFromNib {
  // Stop the base one from logging or doing anything since we don't need it
  // for this test.
}

@end
