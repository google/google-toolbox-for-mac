//
//  NSString+XMLTest.m
//
//  Copyright 2007-2008 Google Inc.
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
#import "GTMNSString+XML.h"


@interface GTMNSString_XMLTest : SenTestCase
@end

@implementation GTMNSString_XMLTest

- (void)testStringByEscapingForXML {
  unichar chars[] =
  { 0, 'z', 1, 'z', 4, 'z', 5, 'z', 34, 'z', 38, 'z', 39, 'z',
    60, 'z', 62, 'z', ' ', 'z', 0xd800, 'z', 0xDFFF, 'z', 0xFFFE,
    0xFFFF, 'z' };

  NSString *string1 = [NSString stringWithCharacters:chars
                                              length:sizeof(chars) / sizeof(unichar)];
  NSString *string2 = @"zzzz&quot;z&amp;z&apos;z&lt;z&gt;z zzzz";

  STAssertEqualObjects([string1 gtm_stringByEscapingForXML],
                       string2,
                       @"Escaped for XML failed");
}

@end
