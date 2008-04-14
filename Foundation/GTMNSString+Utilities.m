//
//  GTMNSString+Utilities.m
//  Misc NSString Utilities
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
#import "GTMNSString+Utilities.h"

@implementation NSString (GTMNSStringUtilitiesAdditions)

- (const unichar*)gtm_UTF16StringWithLength:(size_t*)length {  
  size_t size = [self length];
  const UniChar *buffer = CFStringGetCharactersPtr((CFStringRef)self);
  if (!buffer) {
    size_t memsize = size * sizeof(UniChar);

    // nope, alloc buffer and fetch the chars ourselves
    buffer = malloc(memsize);
    if (!buffer) {
      // COV_NF_BEGIN  - Memory fail case
      _GTMDevLog(@"couldn't alloc buffer");
      return nil;
      // COV_NF_END
    }
    [self getCharacters:(void*)buffer];
    [NSData dataWithBytesNoCopy:(void*)buffer length:size];
  }
  if (length) {
    *length = size;
  }
  return buffer;  
}

@end
