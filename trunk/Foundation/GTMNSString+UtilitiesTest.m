//
//  GTMNSString+UtilitiesTest.m
//  Misc NSString Utilities
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
#import "GTMNSString+Utilities.h"

@interface GTMNSString_UtilitiesTest : SenTestCase
@end

@implementation GTMNSString_UtilitiesTest

- (void)testStringWithLength {
  NSString *string = @"";
  size_t length;
  const unichar *buffer = [string gtm_UTF16StringWithLength:&length];
  STAssertNotNULL(buffer, @"Buffer shouldn't be NULL");
  STAssertEquals(length, 0LU, @"Length should be 0");
  
  UniChar unicharBytes[] = { 0x50, 0x51, 0x52 };
  string = [[[NSString alloc] initWithCharactersNoCopy:unicharBytes 
                                                length:3 
                                          freeWhenDone:NO] autorelease];
  buffer = [string gtm_UTF16StringWithLength:&length];
  STAssertEquals(buffer, 
                 (const unichar*)unicharBytes, 
                 @"Pointers should be equal");
  STAssertEquals(length, 
                 3UL, 
                 nil);
  
  char utf8Bytes[] =  { 0x50, 0x51, 0x52, 0x0 };
  string = [NSString stringWithUTF8String:utf8Bytes];
  buffer = [string gtm_UTF16StringWithLength:&length];
  STAssertNotEquals(buffer, 
                    (const unichar*)utf8Bytes, 
                    @"Pointers should not be equal");
  STAssertEquals(length, 
                 3UL, 
                 nil);
  buffer = [string gtm_UTF16StringWithLength:nil];
  STAssertNotEquals(buffer, 
                    (const unichar*)utf8Bytes, 
                    @"Pointers should not be equal");
}
@end
