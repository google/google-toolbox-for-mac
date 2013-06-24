//
//  GTMObjectSingleton.h
//  Macro to implement a creation method for a singleton
//
//  Copyright 2005-2008 Google Inc.
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

//
// This file has been kept around for compatibility with apps relying on its macro,
// but given how simple this is, there is not a compelling reason for any app to
// use this macro.
//
//  For a reasonable discussion of Objective-C singletons, see
//  http://eschatologist.net/blog/?p=178
//
// Sample usage:
//
// GTMOBJECT_SINGLETON_BOILERPLATE(SomeUsefulManager, sharedSomeUsefulManager)
// (with no trailing semicolon)
//

#include <AvailabilityMacros.h>

#if (defined(__IPHONE_7_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)) \
    || (defined(MAC_OS_X_VERSION_10_9) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9))
#error "GTMOBJECT_SINGLETON_BOILERPLATE is deprecated; change this in your sources to a class method using dispatch_once."
#endif

#if NS_BLOCKS_AVAILABLE

#define GTMOBJECT_SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_) \
+ (_object_name_ *)_shared_obj_name_ {     \
  static _object_name_ *obj;               \
  static dispatch_once_t onceToken;        \
  dispatch_once(&onceToken, ^{             \
     obj = [[self alloc] init];            \
  });                                      \
  return obj;                              \
}

#else

#define GTMOBJECT_SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_) \
+ (_object_name_ *)_shared_obj_name_ {     \
  static _object_name_ *obj;               \
  if (obj == nil) {                        \
    obj = [[self alloc] init];             \
  }                                        \
  return obj;                              \
}

#endif  // NS_BLOCKS_AVAILABLE
