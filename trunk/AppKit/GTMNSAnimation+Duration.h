//
//  GTMNSAnimation+Duration.h
//
//  Copyright 2009 Google Inc.
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

// Categories for changing the duration of an animation based on the current
// event. Right now they track the state of the shift and control keys to slow
// down animations similar to how minimize window animations occur.

#import <AppKit/AppKit.h>
#import "GTMDefines.h"

@interface NSAnimation (GTMNSAnimationDurationAdditions)
- (void)gtm_setDuration:(NSTimeInterval)duration;
@end


#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#import <QuartzCore/QuartzCore.h>

@interface NSAnimationContext (GTMNSAnimationDurationAdditions)
- (void)gtm_setDuration:(NSTimeInterval)duration;
@end

@interface CAAnimation (GTMCAAnimationDurationAdditions)
- (void)gtm_setDuration:(CFTimeInterval)duration;
@end

#endif  // MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
