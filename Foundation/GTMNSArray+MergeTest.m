//
//  GTMNSArray+MergeTest.m
//
//  Copyright 2008 Google Inc.
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
//  License for the specific language governing permissions and limitations
//  under the License.
//

#import "GTMSenTestCase.h"
#import "GTMNSArray+Merge.h"

@interface GTMNSArray_MergeTest : GTMTestCase
@end


@interface NSString (GTMStringMergingTestAdditions)

- (NSString *)mergeString:(NSString *)stringB;

@end


@implementation GTMNSArray_MergeTest

- (void)testMergingTwoEmptyArrays {
  NSArray *emptyArrayA = [NSArray array];
  NSArray *emptyArrayB = [NSArray array];
  NSArray *mergedArray = [emptyArrayA gtm_mergeArray:emptyArrayB
                                       mergeSelector:nil];
  XCTAssertNil(mergedArray,
               @"merge of two empty arrays with no merger should render nil");
}

- (void)testMergingTwoEmptyArraysWithMerger {
  NSArray *emptyArrayA = [NSArray array];
  NSArray *emptyArrayB = [NSArray array];
  NSArray *mergedArray
    = [emptyArrayA gtm_mergeArray:emptyArrayB
                    mergeSelector:@selector(mergeString:)];
  XCTAssertNil(mergedArray,
               @"merge of two empty arrays with merger should render nil");
}

- (void)testMergingEmptyWithNilArray {
  NSArray *emptyArrayA = [NSArray array];
  NSArray *nilArrayB = nil;
  NSArray *mergedArray = [emptyArrayA gtm_mergeArray:nilArrayB
                                       mergeSelector:nil];
  XCTAssertNil(mergedArray,
               @"merge of empty with nil array with no merger should render nil");
}

- (void)testMergingEmptyWithNilArrayWithMerger {
  NSArray *emptyArrayA = [NSArray array];
  NSArray *nilArrayB = nil;
  NSArray *mergedArray
    = [emptyArrayA gtm_mergeArray:nilArrayB
                    mergeSelector:@selector(mergeString:)];
  XCTAssertNil(mergedArray,
               @"merge of empty with nil array with merger should render nil");
}

- (void)testMergingTwoOneItemArraysThatDontMatch {
  NSArray *arrayA = [NSArray arrayWithObject:@"abc.def"];
  NSArray *arrayB = [NSArray arrayWithObject:@"abc.ghi"];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:nil];
  XCTAssertNotNil(mergedArray,
                  @"merge of two non empty arrays with no merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)2,
                 @"merged array should have two items");
  XCTAssertEqualObjects([mergedArray objectAtIndex:0], @"abc.def");
  XCTAssertEqualObjects([mergedArray objectAtIndex:1], @"abc.ghi");
}

- (void)testMergingTwoOneItemArraysThatDontMatchWithMerger {
  NSArray *arrayA = [NSArray arrayWithObject:@"abc.def"];
  NSArray *arrayB = [NSArray arrayWithObject:@"abc.ghi"];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:@selector(mergeString:)];
  XCTAssertNotNil(mergedArray,
                  @"merge of two non empty arrays with merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)2,
                 @"merged array should have two items");
  XCTAssertEqualObjects([mergedArray objectAtIndex:0], @"abc.def");
  XCTAssertEqualObjects([mergedArray objectAtIndex:1], @"abc.ghi");
}

- (void)testMergingTwoOneItemArraysThatMatch {
  NSArray *arrayA = [NSArray arrayWithObject:@"abc.def"];
  NSArray *arrayB = [NSArray arrayWithObject:@"abc.def"];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:nil];
  XCTAssertNotNil(mergedArray,
                  @"merge of two matching arrays with no merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)2,
                 @"merged array with no merger should have two items");
  XCTAssertEqualObjects([mergedArray objectAtIndex:0], @"abc.def");
  XCTAssertEqualObjects([mergedArray objectAtIndex:1], @"abc.def");
}

- (void)testMergingTwoOneItemArraysThatMatchWithMerger {
  NSArray *arrayA = [NSArray arrayWithObject:@"abc.def"];
  NSArray *arrayB = [NSArray arrayWithObject:@"abc.def"];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:@selector(mergeString:)];
  XCTAssertNotNil(mergedArray,
                  @"merge of two matching arrays with merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)1,
                 @"merged array with merger should have one items");
  XCTAssertEqualObjects([mergedArray objectAtIndex:0], @"abc.def");
}

- (void)testMergingMultipleItemArray {
  NSArray *arrayA = [NSArray arrayWithObjects:
                     @"Kansas",
                     @"Arkansas",
                     @"Wisconson",
                     @"South Carolina",
                     nil];
  NSArray *arrayB = [NSArray arrayWithObjects:
                     @"South Carolina",
                     @"Quebec",
                     @"British Columbia",
                     @"Arkansas",
                     @"South Hamptom",
                     nil];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:nil];
  XCTAssertNotNil(mergedArray,
                  @"merge of two non empty arrays with no merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)9,
                 @"merged array should have 9 items");
}

- (void)testMergingMultipleItemArrayWithMerger {
  NSArray *arrayA = [NSArray arrayWithObjects:
                     @"Kansas",
                     @"Arkansas",
                     @"Wisconson",
                     @"South Carolina",
                     nil];
  NSArray *arrayB = [NSArray arrayWithObjects:
                     @"South Carolina",
                     @"Quebec",
                     @"British Columbia",
                     @"Arkansas",
                     @"South Hamptom",
                     nil];
  NSArray *mergedArray = [arrayA gtm_mergeArray:arrayB
                                  mergeSelector:@selector(mergeString:)];
  XCTAssertNotNil(mergedArray,
                  @"merge of two non empty arrays with merger should render "
                  @"an array");
  XCTAssertEqual([mergedArray count], (NSUInteger)7,
                 @"merged array should have 7 items");
}

- (void)testMergeWithEmptyArrays {
  NSArray *arrayA = [NSArray arrayWithObjects:@"xyz", @"abc", @"mno", nil];
  NSArray *arrayB = [NSArray array];
  NSArray *expected = [NSArray arrayWithObjects:@"abc", @"mno", @"xyz", nil];
  XCTAssertNotNil(arrayA);
  XCTAssertNotNil(arrayB);
  XCTAssertNotNil(expected);
  NSArray *mergedArray;

  // no merger
  mergedArray = [arrayA gtm_mergeArray:arrayB
                         mergeSelector:nil];
  XCTAssertNotNil(mergedArray);
  XCTAssertEqualObjects(mergedArray, expected);

  // w/ merger
  mergedArray = [arrayA gtm_mergeArray:arrayB
                         mergeSelector:@selector(mergeString:)];
  XCTAssertNotNil(mergedArray);
  XCTAssertEqualObjects(mergedArray, expected);

  // no merger and array args reversed
  mergedArray = [arrayB gtm_mergeArray:arrayA
                         mergeSelector:nil];
  XCTAssertNotNil(mergedArray);
  XCTAssertEqualObjects(mergedArray, expected);

  // w/ merger and array args reversed
  mergedArray = [arrayB gtm_mergeArray:arrayA
                         mergeSelector:@selector(mergeString:)];
  XCTAssertNotNil(mergedArray);
  XCTAssertEqualObjects(mergedArray, expected);
}

@end


@implementation NSString (GTMStringMergingTestAdditions)

- (NSString *)mergeString:(NSString *)stringB {
  return stringB;
}

@end

