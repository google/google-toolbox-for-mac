//
//  GTMNSFileManager+CarbonTest.m
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
#import "GTMNSFileManager+Carbon.h"
#import <CoreServices/CoreServices.h>

@interface GTMNSFileManager_CarbonTest : GTMTestCase
@end

@implementation GTMNSFileManager_CarbonTest

- (void)testAliasPathFSRefConversion {
  NSString *path = NSHomeDirectory();
  XCTAssertNotNil(path);
  NSFileManager *fileManager = [NSFileManager defaultManager];
  FSRef *fsRef = [fileManager gtm_FSRefForPath:path];
  XCTAssertNotNULL(fsRef);
  AliasHandle alias;
  XCTAssertNoErr(FSNewAlias(nil, fsRef, &alias));
  XCTAssertNotNULL(alias);
  NSData *aliasData = [NSData dataWithBytes:*alias
                                     length:GetAliasSize(alias)];
  XCTAssertNotNil(aliasData);
  NSString *path2 = [fileManager gtm_pathFromAliasData:aliasData];
  XCTAssertEqualObjects(path, path2);

  path2 = [fileManager gtm_pathFromAliasData:aliasData
                                     resolve:YES
                                      withUI:NO];
  XCTAssertEqualObjects(path, path2);

  path2 = [fileManager gtm_pathFromAliasData:aliasData
                                     resolve:NO
                                      withUI:NO];
  XCTAssertEqualObjects(path, path2);

  NSData *aliasData2 = [fileManager gtm_aliasDataForPath:path2];
  XCTAssertNotNil(aliasData2);
  NSString *path3 = [fileManager gtm_pathFromAliasData:aliasData2];
  XCTAssertEqualObjects(path2, path3);
  NSString *path4 = [fileManager gtm_pathFromFSRef:fsRef];
  XCTAssertEqualObjects(path, path4);

  // Failure cases
  XCTAssertNULL([fileManager gtm_FSRefForPath:@"/ptah/taht/dosent/esixt/"]);

  XCTAssertNULL([fileManager gtm_FSRefForPath:@""]);
  XCTAssertNULL([fileManager gtm_FSRefForPath:nil]);
  XCTAssertNil([fileManager gtm_pathFromFSRef:nil]);
  XCTAssertNil([fileManager gtm_pathFromAliasData:nil]);
  XCTAssertNil([fileManager gtm_pathFromAliasData:[NSData data]]);

  XCTAssertNil([fileManager gtm_aliasDataForPath:@"/ptah/taht/dosent/esixt/"]);
  XCTAssertNil([fileManager gtm_aliasDataForPath:@""]);
  XCTAssertNil([fileManager gtm_aliasDataForPath:nil]);
}
@end
