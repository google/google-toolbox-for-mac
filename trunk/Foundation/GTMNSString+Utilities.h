//
//  GTMNSString+Utilities.h
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

#import <Foundation/Foundation.h>

@interface NSString (GTMNSStringUtilitiesAdditions)

// Returns a a UTF16 buffer. Avoids copying the data if at all
// possible for fastest possible/least memory access to the underlying
// unicode characters (UTF16). This returned buffer is NOT null terminated.
// *DANGER* 
// Since we avoid copying data you can only be guaranteed access to 
// the bytes of the data for the lifetime of the string that you have extracted
// the data from. This exists to allow speedy access to the underlying buffer
// and guaranteed memory cleanup if memory needs to be allocated.
// Do not free the returned pointer.
//
// Args:
//    length - returns the number of unichars in the buffer. Send in nil if
//             you don't care.
//
// Returns:
//    pointer to the buffer. Nil on failure.
- (const unichar*)gtm_UTF16StringWithLength:(size_t*)length;
@end
