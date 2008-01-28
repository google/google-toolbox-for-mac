//
//  GTMNSEnumerator+FilterTest.m
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
#import "GTMNSEnumerator+Filter.h"

@interface GTMNSEnumerator_FilterTest : SenTestCase
@end

@implementation GTMNSEnumerator_FilterTest

// test using an NSSet enumerator.
- (void)testEnumeratorByMakingEachObjectPerformSelector {
  NSSet *numbers = [NSSet setWithObjects: @"1", @"2", @"3", nil];
  NSEnumerator *e = [[numbers objectEnumerator]
    gtm_enumeratorByMakingEachObjectPerformSelector:@selector(stringByAppendingString:) 
                                         withObject:@" "];
  NSMutableSet *trailingSpaces = [NSMutableSet set];
  id obj;
  while (nil != (obj = [e nextObject])) {
    [trailingSpaces addObject:obj];
  }
  NSSet *trailingSpacesGood = [NSSet setWithObjects: @"1 ", @"2 ", @"3 ", nil];
  STAssertEqualObjects(trailingSpaces, trailingSpacesGood, @"");
  NSSet *empty = [NSSet set];
  NSEnumerator *ee = [[empty objectEnumerator]
    gtm_enumeratorByMakingEachObjectPerformSelector:@selector(stringByAppendingString:) 
                                         withObject:@" "];

  NSMutableSet *emptySpaces = [NSMutableSet set];
  while (nil != (obj = [ee nextObject])) {
    [emptySpaces addObject:obj];
  }
  STAssertEqualObjects(empty, emptySpaces, @"");
}

// test using an NSDictionary enumerator.
- (void)testFilteredEnumeratorByMakingEachObjectPerformSelector {
  NSDictionary *numbers = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"1", @"", @"", @"3", @"3", nil];

  // |length| filters out length 0 objects
  NSEnumerator *e = [[numbers objectEnumerator]
    gtm_filteredEnumeratorByMakingEachObjectPerformSelector:@selector(length) 
                                                 withObject:nil];

  NSArray *lengths = [e allObjects];
  NSArray *lengthsGood = [NSArray arrayWithObjects: @"1", @"3", nil];
  STAssertEqualObjects(lengths, lengthsGood, @"");
}



@end
