//
//  GTMNSFileManager+PathTest.m
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
#import "GTMNSFileManager+Path.h"

@interface GTMNSFileManager_PathTest : SenTestCase
@end
  
@implementation GTMNSFileManager_PathTest

#if MAC_OS_X_VERSION_MIN_REQUIRED < 1050

- (void)testCreateFullPathToDirectoryAttributes {
  NSString *baseDir =
    [NSTemporaryDirectory() stringByAppendingPathComponent:@"testCreateFullPathToDirectoryAttributes"];
  NSString *testPath = [baseDir stringByAppendingPathComponent:@"/foo/bar/baz"];
  NSFileManager *fm = [NSFileManager defaultManager];
  
  STAssertFalse([fm fileExistsAtPath:testPath],
                @"You must delete '%@' before running this test", baseDir);
  
  STAssertTrue([fm gtm_createFullPathToDirectory:testPath attributes:nil],
               @"Failed to create nested testPath");
  
  STAssertTrue([fm removeFileAtPath:baseDir handler:nil],
               @"Failed to delete \'%@\'", baseDir);
  
  NSString *pathToFail = [@"/etc" stringByAppendingPathComponent:testPath];
  STAssertFalse([fm gtm_createFullPathToDirectory:pathToFail attributes:nil],
                @"We were allowed to create a dir in '/etc'?!");
  
  STAssertFalse([fm gtm_createFullPathToDirectory:nil attributes:nil],
                @"Should have failed when passed (nil)");
}

#endif // MAC_OS_X_VERSION_MIN_REQUIRED < 1050

- (void)testfilePathsWithExtensionsInDirectory {
  // TODO: need a test for filePathsWithExtensions:inDirectory:
}

@end
