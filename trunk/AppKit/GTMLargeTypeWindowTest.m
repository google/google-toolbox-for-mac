//
//  GTMLargeTypeWindowTest.m
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
#import "GTMLargeTypeWindow.h"
#import "GTMNSObject+UnitTesting.h"
#import "GTMUnitTestDevLog.h"

NSString *const kLongTextBlock = 
  @"`Twas brillig, and the slithy toves "
  "Did gyre and gimble in the wabe: "
  "all mimsy were the borogoves, "
  "and the mome raths outgrabe. "
  "Beware the Jabberwock, my son! "
  "The jaws that bite, the claws that catch! "
  "Beware the Jubjub bird, and shun "
  "the frumious Bandersnatch! "
  "He took his vorpal sword in hand: "
  "long time the manxome foe he sought -- "
  "so rested he by the Tumtum tree, "
  "and stood awhile in thought. "
  "And, as in uffish thought he stood, "
  "the Jabberwock, with eyes of flame, "
  "came whiffling through the tulgey wood, "
  "and burbled as it came! "
  "One, two! One, two! And through and through "
  "the vorpal blade went snicker-snack! "
  "He left it dead, and with its head "
  "he went galumphing back. "
  "And, has thou slain the Jabberwock? "
  "Come to my arms, my beamish boy! "
  "O frabjous day! Callooh! Callay! "
  "He chortled in his joy.";

NSString *const kMediumTextBlock = @"For the Snark was a Boojum, you see.";

@interface GTMLargeTypeWindowTest : GTMTestCase
@end

@implementation GTMLargeTypeWindowTest
- (void)testLargeTypeWindow {
  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty string"];
  GTMLargeTypeWindow *window = [[[GTMLargeTypeWindow alloc] 
                                 initWithString:@""] autorelease];
  STAssertNil(window, nil);
  
  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty string"];
  window = [[[GTMLargeTypeWindow alloc] initWithString:nil] autorelease];
  STAssertNil(window, nil);
  
  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty string"];
  NSAttributedString *attrString = [[[NSAttributedString alloc] 
                                     initWithString:@""] autorelease];
  window = [[[GTMLargeTypeWindow alloc] 
             initWithAttributedString:attrString] autorelease];
  STAssertNil(window, nil);
  
  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty string"];
  window = [[[GTMLargeTypeWindow alloc] 
             initWithAttributedString:nil] autorelease];
  STAssertNil(window, nil);

  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty view"];
  window = [[[GTMLargeTypeWindow alloc] initWithContentView:nil] autorelease];
  STAssertNil(window, nil);

  [GTMUnitTestDevLog expectString:@"GTMLargeTypeWindow got an empty image"];
  window = [[[GTMLargeTypeWindow alloc] initWithImage:nil] autorelease];
  STAssertNil(window, nil);
  
  window = [[[GTMLargeTypeWindow alloc] 
             initWithString:kMediumTextBlock] autorelease];
  STAssertNotNil(window, nil);
  STAssertTrue([window canBecomeKeyWindow], nil);
  [window makeKeyAndOrderFront:nil];
  NSDate *endDate 
    = [NSDate dateWithTimeIntervalSinceNow:kGTMLargeTypeWindowFadeTime];
  [[NSRunLoop currentRunLoop] runUntilDate:endDate];
  GTMAssertObjectStateEqualToStateNamed(window, 
                                        @"GTMLargeTypeWindowMediumTextTest",
                                        nil); 
  [window copy:nil];
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSString *pbString = [pb stringForType:NSStringPboardType];
  STAssertEqualObjects(pbString, kMediumTextBlock, nil);
  [window keyDown:nil];
  
  window = [[[GTMLargeTypeWindow alloc] initWithString:@"Short"] autorelease];
  STAssertNotNil(window, nil);
  STAssertTrue([window canBecomeKeyWindow], nil);
  [window makeKeyAndOrderFront:nil];
  endDate = [NSDate dateWithTimeIntervalSinceNow:kGTMLargeTypeWindowFadeTime];
  [[NSRunLoop currentRunLoop] runUntilDate:endDate];
  GTMAssertObjectStateEqualToStateNamed(window, 
                                        @"GTMLargeTypeWindowShortTextTest",
                                        nil); 
  [window copy:nil];
  pbString = [pb stringForType:NSStringPboardType];
  STAssertEqualObjects(pbString, @"Short", nil);
  [window resignKeyWindow];

  window = [[[GTMLargeTypeWindow alloc] 
             initWithString:kLongTextBlock] autorelease];
  STAssertNotNil(window, nil);
  [window orderFront:nil];
  endDate = [NSDate dateWithTimeIntervalSinceNow:kGTMLargeTypeWindowFadeTime];
  [[NSRunLoop currentRunLoop] runUntilDate:endDate];
  // Can't do state for long text as it will wrap differently on different
  // sized screens.
  GTMAssertObjectStateEqualToStateNamed(window,
                                        @"GTMLargeTypeWindowLongTextTest", 
                                        nil); 
  [window keyDown:nil];
  
  NSImage *image = [NSApp applicationIconImage];
  window = [[[GTMLargeTypeWindow alloc] initWithImage:image] autorelease];
  STAssertNotNil(window, nil);
  [window makeKeyAndOrderFront:nil];
  endDate = [NSDate dateWithTimeIntervalSinceNow:kGTMLargeTypeWindowFadeTime];
  [[NSRunLoop currentRunLoop] runUntilDate:endDate];
  GTMAssertObjectStateEqualToStateNamed(window, 
                                        @"GTMLargeTypeWindowImageTest",
                                        nil);
  [window copy:nil];
  // Pasteboard should not change for an image
  pbString = [pb stringForType:NSStringPboardType];
  STAssertEqualObjects(pbString, @"Short", nil);
  [window resignKeyWindow];
}

@end
