//
//  GTMIBArray.m
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


#import "GTMIBArray.h"
#import "GTMDefines.h"

@implementation GTMIBArray

- (void)dealloc {
  [realArray_ release];
  [super dealloc];
}

- (void)setupRealArray {

#ifdef DEBUG
  // It is very easy to create a cycle if you are chaining these in IB, so in
  // debug builds, we try to catch this to inform the developer.  Use -[NSArray
  // indexOfObjectIdenticalTo:] to get pointer comparisons instead of object
  // equality.
  static NSMutableArray *ibArraysBuilding = nil;
  if (!ibArraysBuilding) {
    ibArraysBuilding = [[NSMutableArray alloc] init];
  }
  _GTMDevAssert([ibArraysBuilding indexOfObjectIdenticalTo:self] == NSNotFound,
                @"There is a cycle in your GTMIBArrays!");
  [ibArraysBuilding addObject:self];
#endif  // DEBUG

  // Build the array up.
  NSMutableArray *builder = [NSMutableArray array];
  Class ibArrayClass = [GTMIBArray class];
  id objs[] = {
    object1_, object2_, object3_, object4_, object5_,
  };
  for (size_t idx = 0 ; idx < sizeof(objs) / (sizeof(objs[0])) ; ++idx) {
    id obj = objs[idx];
    if (obj) {
      if ([obj isKindOfClass:ibArrayClass]) {
        [builder addObjectsFromArray:obj];
      } else {
        [builder addObject:obj];
      }
    }
  }

#ifdef DEBUG
  [ibArraysBuilding removeObject:self];
#endif  // DEBUG

  // Now copy with our zone.
  realArray_ = [builder copyWithZone:[self zone]];
}

// ----------------------------------------------------------------------------
// NSArray has two methods that everything else seems to work on, simply
// implement those.

- (NSUInteger)count {
  if (!realArray_) [self setupRealArray];
  return [realArray_ count];
}

- (id)objectAtIndex:(NSUInteger)idx {
  if (!realArray_) [self setupRealArray];
  return [realArray_ objectAtIndex:idx];
}

// ----------------------------------------------------------------------------
// Directly relay the enumeration based calls just in case there is some extra
// efficency to be had.

- (NSEnumerator *)objectEnumerator {
  if (!realArray_) [self setupRealArray];
  return [realArray_ objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator {
  if (!realArray_) [self setupRealArray];
  return [realArray_ reverseObjectEnumerator];
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len {
  if (!realArray_) [self setupRealArray];
  return [realArray_ countByEnumeratingWithState:state
                                         objects:stackbuf
                                           count:len];
}

#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5

// ----------------------------------------------------------------------------
// Directly relay the copy methods, again, for any extra efficency.

- (id)copyWithZone:(NSZone *)zone {
  if (!realArray_) [self setupRealArray];
  return [realArray_ copyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
  if (!realArray_) [self setupRealArray];
  return [realArray_ mutableCopyWithZone:zone];
}

@end
