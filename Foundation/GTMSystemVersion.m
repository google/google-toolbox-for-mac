//
//  GTMSystemVersion.m
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

#import "GTMSystemVersion.h"

static int sGTMSystemVersionMajor = 0;
static int sGTMSystemVersionMinor = 0;
static int sGTMSystemVersionBugFix = 0;

@implementation GTMSystemVersion
+ (void)initialize {
  if (self == [GTMSystemVersion class]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *systemVersionPlist = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *version = [systemVersionPlist objectForKey:@"ProductVersion"];
    _GTMDevAssert(version, @"Unable to get version");
    NSArray *versionInfo = [version componentsSeparatedByString:@"."];
    int length = [versionInfo count];
    _GTMDevAssert(length > 1 && length < 4, @"Unparseable version %@", version);
    sGTMSystemVersionMajor = [[versionInfo objectAtIndex:0] intValue];
    _GTMDevAssert(sGTMSystemVersionMajor != 0, @"Unknown version for %@", version);
    sGTMSystemVersionMinor = [[versionInfo objectAtIndex:1] intValue];
    if (length == 3) {
      sGTMSystemVersionBugFix = [[versionInfo objectAtIndex:2] intValue];
    }
    [pool release];
  }
}

+ (void)getMajor:(long*)major minor:(long*)minor bugFix:(long*)bugFix {
  if (major) {
    *major = sGTMSystemVersionMajor;
  }
  if (minor) {
    *minor = sGTMSystemVersionMinor;
  }
  if (major) {
    *bugFix = sGTMSystemVersionBugFix;
  }
}

#if GTM_MACOS_SDK
+ (BOOL)isPanther {
  return sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor == 3;
}

+ (BOOL)isTiger {
  return sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor == 4;
}

+ (BOOL)isLeopard {
  return sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor == 5;
}

+ (BOOL)isPantherOrGreater {
  return (sGTMSystemVersionMajor > 10) || 
          (sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor >= 3);
}

+ (BOOL)isTigerOrGreater {
  return (sGTMSystemVersionMajor > 10) || 
          (sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor >= 4);
}

+ (BOOL)isLeopardOrGreater {
  return (sGTMSystemVersionMajor > 10) || 
          (sGTMSystemVersionMajor == 10 && sGTMSystemVersionMinor >= 5);
}

#endif // GTM_IPHONE_SDK

@end
