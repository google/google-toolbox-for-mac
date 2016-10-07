//
//  GTMLoginItemsTest.m
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
#import "GTMLoginItems.h"

  // we don't really run this test because if someone had it in some automated
  // tests, then if something did fail, it could leave things in the login items
  // on the computer which could be a nasty surprise.
#define MODIFICATION_TESTS_ENABLED 0


@interface GTMLoginItemsTest : GTMTestCase
@end

static BOOL ItemsListHasPath(NSArray *items, NSString *path) {
  NSDictionary *item = nil;
  for (item in items) {
    NSString *itemPath = [item objectForKey:kGTMLoginItemsPathKey];
    if (itemPath && [itemPath isEqual:path]) {
      return YES;
    }
  }
  return NO;
}

@implementation GTMLoginItemsTest

- (void)testNoModification {

  NSError *error = nil;
  NSString *bogusAppPath = @"/Applications/AppThatDoesNotExist.app";
  NSString *bogusAppName = @"AppThatDoesNotExist";

  // fetch the starting values
  NSArray *initialItems = [GTMLoginItems loginItems:&error];
  XCTAssertNotNil(initialItems, @"shouldn't be nil (%@)", error);
  XCTAssertFalse(ItemsListHasPath(initialItems, bogusAppPath),
                 @"bogusApp shouldn't be in list to start for test (%@)",
                 initialItems);

  // check by path
  XCTAssertFalse([GTMLoginItems pathInLoginItems:bogusAppPath]);

  // check by name
  XCTAssertFalse([GTMLoginItems itemWithNameInLoginItems:bogusAppName]);

  // remove it by path
  [GTMLoginItems removePathFromLoginItems:bogusAppPath];
  NSArray *curItems = [GTMLoginItems loginItems:nil];
  XCTAssertEqualObjects(initialItems, curItems);

  // remove it by name
  [GTMLoginItems removeItemWithNameFromLoginItems:bogusAppName];
  curItems = [GTMLoginItems loginItems:nil];
  XCTAssertEqualObjects(initialItems, curItems);

}

- (void)testModification {

#if MODIFICATION_TESTS_ENABLED

  NSError *error = nil;
  NSString *textEditPath = @"/Applications/TextEdit.app";
  NSString *textEditName = @"TextEdit";

  // fetch the starting values
  NSArray *initialItems = [GTMLoginItems loginItems:&error];
  XCTAssertNotNil(initialItems, @"shouldn't be nil (%@)", error);
  XCTAssertFalse(ItemsListHasPath(initialItems, textEditPath),
                 @"textedit shouldn't be in list to start for test (%@)",
                 initialItems);

  // add textedit
  [GTMLoginItems addPathToLoginItems:textEditPath hide:NO];
  NSArray *curItems = [GTMLoginItems loginItems:nil];
  XCTAssertNotEqualObjects(initialItems, curItems);

  // check by path
  XCTAssertTrue([GTMLoginItems pathInLoginItems:textEditPath]);

  // check by name
  XCTAssertTrue([GTMLoginItems itemWithNameInLoginItems:textEditName]);

  // remove it by path
  [GTMLoginItems removePathFromLoginItems:textEditPath];
  curItems = [GTMLoginItems loginItems:nil];
  STAssertEqualObjects(initialItems, curItems);

  // check by path
  XCTAssertFalse([GTMLoginItems pathInLoginItems:textEditPath]);

  // check by name
  XCTAssertFalse([GTMLoginItems itemWithNameInLoginItems:textEditName]);

  // add textedit
  [GTMLoginItems addPathToLoginItems:textEditPath hide:NO];
  curItems = [GTMLoginItems loginItems:nil];
  STAssertNotEqualObjects(initialItems, curItems);

  // check by path
  XCTAssertTrue([GTMLoginItems pathInLoginItems:textEditPath]);

  // check by name
  XCTAssertTrue([GTMLoginItems itemWithNameInLoginItems:textEditName]);

  // remove it by name
  [GTMLoginItems removeItemWithNameFromLoginItems:textEditName];
  curItems = [GTMLoginItems loginItems:nil];
  XCTAssertEqualObjects(initialItems, curItems);

  // check by path
  XCTAssertFalse([GTMLoginItems pathInLoginItems:textEditPath]);

  // check by name
  XCTAssertFalse([GTMLoginItems itemWithNameInLoginItems:textEditName]);

#endif // MODIFICATION_TESTS_ENABLED

}

@end
