//
//  GTMNSAnimation+Duration.m
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

#import "GTMNSAnimation+Duration.h"

static NSTimeInterval GTMCurrentDurationMultiplier(void) {
  NSEvent *event = [NSApp currentEvent];
  NSUInteger modifiers = [event modifierFlags];
  NSTimeInterval duration = 1.0;
  if (modifiers & NSShiftKeyMask) {
    duration *= 0.2;
  }
  // These are additive, so shift+control returns 0.1 * duration.
  if (modifiers & NSControlKeyMask) {
    duration *= 0.5;
  }
  return duration;
}

@implementation NSAnimation (GTMNSAnimationDurationAdditions)

- (void)gtm_setDuration:(NSTimeInterval)duration {
  duration = duration * GTMCurrentDurationMultiplier();
  [self setDuration:duration];
}

@end

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

@implementation CAAnimation (GTMCAAnimationDurationAdditions)

- (void)gtm_setDuration:(CFTimeInterval)duration {
  duration = duration * GTMCurrentDurationMultiplier();
  [self setDuration:duration];
}

@end

#endif  // MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
