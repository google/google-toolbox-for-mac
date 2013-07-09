//
//  GTMIPhoneUnitTestMain.m
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
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMDefines.h"
#if !GTM_IPHONE_SDK
  #error GTMIPhoneUnitTestMain for iPhone only
#endif
#import <UIKit/UIKit.h>

// Creates an application that runs all tests from classes extending
// SenTestCase, outputs results and test run time, and terminates right
// afterwards.
int main(int argc, char *argv[]) {
  int retVal;
#if __has_feature(objc_arc)
  @autoreleasepool {
#else
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#endif
#if GTM_IPHONE_USE_SENTEST
  // Is using SenTest, just create a dummy app that can be used as the
  // TEST_HOST.
  retVal = UIApplicationMain(argc, argv, nil, nil);
#else
  retVal = UIApplicationMain(argc, argv, nil, @"GTMIPhoneUnitTestDelegate");
#endif
#if __has_feature(objc_arc)
  }
#else
  [pool release];
#endif
  return retVal;
}
