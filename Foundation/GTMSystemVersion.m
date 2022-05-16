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

#pragma clang diagnostic push
// Ignore all of the deprecation warnings for GTMSystemVersion.h
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

#import <objc/message.h>
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

#if GTM_MACOS_SDK
#import <CoreServices/CoreServices.h>
#else
// On iOS we cheat and pull in the header for UIDevice to get the selectors,
// but call it via runtime since GTMSystemVersion is supposed to only depend on
// Foundation.
#import "UIKit/UIDevice.h"
#endif

static SInt32 sGTMSystemVersionMajor = 0;
static SInt32 sGTMSystemVersionMinor = 0;
static SInt32 sGTMSystemVersionBugFix = 0;
static NSString *sBuild = nil;

NSString *const kGTMArch_iPhone = @"iPhone";
NSString *const kGTMArch_x86_64 = @"x86_64";
NSString *const kGTMArch_i386 = @"i386";

static NSString *const kSystemVersionPlistPath = @"/System/Library/CoreServices/SystemVersion.plist";

@implementation GTMSystemVersion
+ (void)initialize {
  if (self == [GTMSystemVersion class]) {
#if GTM_MACOS_SDK && (MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10)
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
      NSOperatingSystemVersion osVersion = [processInfo operatingSystemVersion];
      sGTMSystemVersionMajor = (SInt32)osVersion.majorVersion;
      sGTMSystemVersionMinor = (SInt32)osVersion.minorVersion;
      sGTMSystemVersionBugFix = (SInt32)osVersion.patchVersion;
    } else {
      // Gestalt() is deprected in 10.8, and the recommended replacement is sysctl.
      // https://developer.apple.com/library/mac/releasenotes/General/CarbonCoreDeprecations/index.html#//apple_ref/doc/uid/TP40012224-CH1-SW16
      // We will use the Darwin version to extract the OS version.
      // NOTE: this only has to up until 10.10, as at that point, the
      // selector test will pass.
      const int kBufferSize = 128;
      char buffer[kBufferSize];
      size_t bufferSize = kBufferSize;
      int ctl_name[] = {CTL_KERN, KERN_OSRELEASE};
      int result = sysctl(ctl_name, 2, buffer, &bufferSize, NULL, 0);
      _GTMDevAssert(result == 0,
                    @"sysctl failed to rertieve the OS version. Error: %d",
                    errno);
      if (result != 0) {
        return;
      }
      buffer[kBufferSize - 1] = 0;  // Paranoid.

      // The buffer now contains a string of the form XX.YY.ZZ, where
      // XX is the major kernel version component and YY is the +1 fixlevel
      // version of the OS.
      SInt32 rawMinor;
      SInt32 rawBugfix;
      int numScanned = sscanf(buffer, "%d.%d", &rawMinor, &rawBugfix);
      _GTMDevAssert(numScanned >= 1,
                    @"sysctl failed to parse the OS version: %s",
                    buffer);
      if (numScanned < 1) {
        return;
      }
      _GTMDevAssert(rawMinor > 4, @"Unexpected raw version: %s", buffer);
      if (rawMinor <= 4) {
        return;
      }
      sGTMSystemVersionMajor = 10;
      sGTMSystemVersionMinor = rawMinor - 4;
      // Note that Beta versions of the OS may have the bugfix missing or set to 0
      if (numScanned > 1 && rawBugfix > 0) {
        sGTMSystemVersionBugFix = rawBugfix - 1;
      }
    }
#else
    NSOperatingSystemVersion osVersion =
        [[NSProcessInfo processInfo] operatingSystemVersion];
    sGTMSystemVersionMajor = (SInt32)osVersion.majorVersion;
    sGTMSystemVersionMinor = (SInt32)osVersion.minorVersion;
    sGTMSystemVersionBugFix = (SInt32)osVersion.patchVersion;
#endif
  }
}

+ (void)getMajor:(SInt32*)major minor:(SInt32*)minor bugFix:(SInt32*)bugFix {
  if (major) {
    *major = sGTMSystemVersionMajor;
  }
  if (minor) {
    *minor = sGTMSystemVersionMinor;
  }
  if (bugFix) {
    *bugFix = sGTMSystemVersionBugFix;
  }
}

+ (NSString*)build {
  @synchronized(self) {
    // Not cached at initialization time because we don't expect "real"
    // software to want this, and it costs a bit to get at startup.
    // This will mainly be for unit test cases.
    if (!sBuild) {
      NSDictionary *systemVersionPlist
        = [NSDictionary dictionaryWithContentsOfFile:kSystemVersionPlistPath];
      sBuild = [[systemVersionPlist objectForKey:@"ProductBuildVersion"] retain];
      _GTMDevAssert(sBuild, @"Unable to get build version");
    }
  }
  return sBuild;
}

+ (BOOL)isBuildLessThan:(NSString*)build {
  NSComparisonResult result
    = [[self build] compare:build
                    options:NSNumericSearch | NSCaseInsensitiveSearch];
  return result == NSOrderedAscending;
}

+ (BOOL)isBuildLessThanOrEqualTo:(NSString*)build {
  NSComparisonResult result
    = [[self build] compare:build
                    options:NSNumericSearch | NSCaseInsensitiveSearch];
  return result != NSOrderedDescending;
}

+ (BOOL)isBuildGreaterThan:(NSString*)build {
  NSComparisonResult result
    = [[self build] compare:build
                    options:NSNumericSearch | NSCaseInsensitiveSearch];
  return result == NSOrderedDescending;
}

+ (BOOL)isBuildGreaterThanOrEqualTo:(NSString*)build {
  NSComparisonResult result
    = [[self build] compare:build
                    options:NSNumericSearch | NSCaseInsensitiveSearch];
  return result != NSOrderedAscending;
}

+ (BOOL)isBuildEqualTo:(NSString *)build {
  NSComparisonResult result
    = [[self build] compare:build
                    options:NSNumericSearch | NSCaseInsensitiveSearch];
  return result == NSOrderedSame;
}

+ (NSString *)runtimeArchitecture {
  NSString *architecture = nil;
#if GTM_IPHONE_SDK
  architecture = kGTMArch_iPhone;
#else // !GTM_IPHONE_SDK
  // In reading arch(3) you'd thing this would work:
  //
  // const NXArchInfo *localInfo = NXGetLocalArchInfo();
  // _GTMDevAssert(localInfo && localInfo->name, @"Couldn't get NXArchInfo");
  // const NXArchInfo *genericInfo = NXGetArchInfoFromCpuType(localInfo->cputype, 0);
  // _GTMDevAssert(genericInfo && genericInfo->name, @"Couldn't get generic NXArchInfo");
  // extensions[0] = [NSString stringWithFormat:@".%s", genericInfo->name];
  //
  // but on 64bit it returns the same things as on 32bit, so...
#if __LP64__
  architecture = kGTMArch_x86_64;
#else // !__LP64__
  architecture = kGTMArch_i386;
#endif // __LP64__

#endif // GTM_IPHONE_SDK
  return architecture;
}

@end

#pragma clang diagnostic pop
