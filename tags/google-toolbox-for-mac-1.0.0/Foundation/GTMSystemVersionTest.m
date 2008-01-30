//
//  GTMSystemVersionTest.m
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
#import "GTMSystemVersion.h"

@interface GTMSystemVersionTest : SenTestCase
@end

@implementation GTMSystemVersionTest
- (void)testBasics {
  long major;
  long minor;
  long bugFix;
  
  [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
  STAssertTrue(major >= 10 && minor >= 3 && bugFix >= 0, nil);
  STAssertTrue([GTMSystemVersion isPantherOrGreater], nil);
  if (minor > 3) {
    STAssertTrue([GTMSystemVersion isTigerOrGreater], nil);
  } else {
    STAssertFalse([GTMSystemVersion isTigerOrGreater], nil);
  }
  if (minor > 4) {
    STAssertTrue([GTMSystemVersion isLeopardOrGreater], nil);
  } else {
    STAssertFalse([GTMSystemVersion isLeopardOrGreater], nil);
  }  
  [GTMSystemVersion getMajor:nil minor:nil bugFix:nil];
}

@end
