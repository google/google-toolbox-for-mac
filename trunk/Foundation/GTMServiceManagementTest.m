//
//  GTMServiceManagementTest.m
//
//  Copyright 2010 Google Inc.
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

#import "GTMServiceManagement.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4

#import "GTMSenTestCase.h"
#import "GTMGarbageCollection.h"

#define STANDARD_JOB_LABEL "com.apple.launchctl.Background"
#define OUR_JOB_LABEL "com.google.gtm.GTMServiceManagementTest.job"
#define BAD_JOB_LABEL "com.google.gtm.GTMServiceManagementTest.badjob"

@interface GTMServiceManagementTest : GTMTestCase
@end

@implementation GTMServiceManagementTest

- (void)testDataConversion {
  const char *someData = "someData";
  NSDictionary *subDict
    = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithBool:1], @"BoolValue",
       [NSNumber numberWithInt:2], @"IntValue",
       [NSNumber numberWithDouble:0.3], @"DoubleValue",
       @"A String", @"StringValue",
       [NSData dataWithBytes:someData length:strlen(someData)], @"DataValue",
       nil];
  NSArray *subArray
    = [NSArray arrayWithObjects:@"1", [NSNumber numberWithInt:2], nil];
  NSDictionary *topDict = [NSDictionary dictionaryWithObjectsAndKeys:
                           subDict, @"SubDict",
                           subArray, @"SubArray",
                           @"Random String", @"RandomString",
                           nil];
  CFErrorRef error = NULL;
  launch_data_t launchDict = GTMLaunchDataCreateFromCFType(topDict, &error);
  STAssertNotNULL(launchDict, nil);
  STAssertNULL(error, @"Error: %@", error);
  NSDictionary *nsDict
    = GTMCFAutorelease(GTMCFTypeCreateFromLaunchData(launchDict,
                                                     NO,
                                                     &error));
  STAssertNotNil(nsDict, nil);
  STAssertNULL(error, @"Error: %@", error);
  STAssertEqualObjects(nsDict, topDict, @"");

  launch_data_free(launchDict);

  // Test a bad type
  NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
  STAssertNotNil(url, nil);
  launchDict = GTMLaunchDataCreateFromCFType(url, &error);
  STAssertNULL(launchDict, nil);
  STAssertNotNULL(error, nil);
  STAssertEqualObjects((id)CFErrorGetDomain(error),
                       (id)kCFErrorDomainPOSIX, nil);
  STAssertEquals(CFErrorGetCode(error), (CFIndex)EINVAL, nil);
  CFRelease(error);

  CFTypeRef cfType = GTMCFTypeCreateFromLaunchData(NULL, YES, &error);
  STAssertNULL(cfType, nil);
  STAssertNotNULL(error, nil);
  CFRelease(error);
}

- (void)testJobDictionaries {
  NSDictionary *jobs = GTMCFAutorelease(GTMSMCopyAllJobDictionaries());
  STAssertNotNil(jobs, nil);
  // A job that should always be around
  NSDictionary *job
    = GTMCFAutorelease(GTMSMJobCopyDictionary(CFSTR(STANDARD_JOB_LABEL)));
  STAssertNotNil(job, nil);

  // A job that should never be around
  CFTypeRef type = GTMSMJobCopyDictionary(CFSTR(BAD_JOB_LABEL));
  STAssertNULL(type, nil);
}

- (void)testLaunching {
  CFErrorRef error = NULL;
  Boolean isGood = GTMSMJobSubmit(NULL, &error);
  STAssertFalse(isGood, nil);
  STAssertNotNULL(error, nil);
  CFRelease(error);

  NSDictionary *empty = [NSDictionary dictionary];
  isGood = GTMSMJobSubmit((CFDictionaryRef)empty, &error);
  STAssertFalse(isGood, nil);
  STAssertNotNULL(error, nil);
  CFRelease(error);

  NSDictionary *alreadyThere
    = [NSDictionary dictionaryWithObject:@STANDARD_JOB_LABEL
                                  forKey:@LAUNCH_JOBKEY_LABEL];
  isGood = GTMSMJobSubmit((CFDictionaryRef)alreadyThere, &error);
  STAssertFalse(isGood, nil);
  STAssertEquals([(NSError *)error code], (NSInteger)EEXIST, nil);
  CFRelease(error);

  NSDictionary *emptyJob
    = [NSDictionary dictionaryWithObject:@"Empty Job"
                                  forKey:@LAUNCH_JOBKEY_LABEL];
  isGood = GTMSMJobSubmit((CFDictionaryRef)emptyJob, &error);
  STAssertFalse(isGood, nil);
  STAssertEquals([(NSError *)error code], (NSInteger)EINVAL, nil);
  CFRelease(error);

  NSDictionary *goodJob
    = [NSDictionary dictionaryWithObjectsAndKeys:
       @OUR_JOB_LABEL, @LAUNCH_JOBKEY_LABEL,
       @"/bin/test", @LAUNCH_JOBKEY_PROGRAM,
       nil];
  isGood = GTMSMJobSubmit((CFDictionaryRef)goodJob, &error);
  STAssertTrue(isGood, nil);
  STAssertNULL(error, nil);

  isGood = GTMSMJobRemove(CFSTR(OUR_JOB_LABEL), &error);
  STAssertTrue(isGood,
               @"You may need to run launchctl remove %s", OUR_JOB_LABEL);
  STAssertNULL(error, nil);

  isGood = GTMSMJobRemove(CFSTR(OUR_JOB_LABEL), &error);
  STAssertFalse(isGood, nil);
  STAssertNotNULL(error, nil);
  CFRelease(error);
}

- (void)testCheckin {
  CFErrorRef error = NULL;
  // TODO(dmaclach): to actually test checkin we would need a subprocess to
  //                 launch, which is too complex at this point. Perhaps
  //                 in the future if bugs are found.
  NSDictionary *badTest
    = GTMCFAutorelease(GTMSMJobCheckIn(&error));
  STAssertNil(badTest, nil);
  STAssertNotNULL(error, nil);
  CFRelease(error);
}

@end

#endif //  if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4
