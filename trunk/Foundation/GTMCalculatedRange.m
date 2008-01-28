//
//  GTMCalculatedRange.m
//
//  Copyright 2006-2008 Google Inc.
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

#import "GTMCalculatedRange.h"

//  Our internal storage type. It keeps track of an item and it's
//  position.
@interface GTMCalculatedRangeStopPrivate : NSObject {
  id item_; // the item (STRONG)
  float position_; //
}
+ (id)stopWithObject:(id)item position:(float)inPosition;
- (id)initWithObject:(id)item position:(float)inPosition;
- (id)item;
- (float)position;
@end


@implementation GTMCalculatedRangeStopPrivate
+ (id)stopWithObject:(id)item position:(float)inPosition {
  return [[[[self class] alloc] initWithObject:item position:inPosition] autorelease];
}

- (id)initWithObject:(id)item position:(float)inPosition {
  self = [super init];
  if (self != nil) {
    item_ = [item retain];
    position_ = inPosition;
  }
  return self;
}

- (void)dealloc {
  [item_ release];
  [super dealloc];
}

- (id)item {
  return item_;
}

- (float)position {
  return position_;
}

- (NSString *)description {
  return [NSString stringWithFormat: @"%f %@", position_, item_];
}
@end

@implementation GTMCalculatedRange
- (id)init {
  self = [super init];
  if (self != nil) {
    storage_ = [[NSMutableArray arrayWithCapacity:0] retain]; 
  }
  return self;
}
- (void)dealloc {
  [storage_ release];
  [super dealloc];
}

- (void)insertStop:(id)item atPosition:(float)position {
  unsigned int index = 0;
  NSEnumerator *theEnumerator = [storage_ objectEnumerator];
  GTMCalculatedRangeStopPrivate *theStop;
  while (nil != (theStop = [theEnumerator nextObject])) {
    if ([theStop position] < position) {
      index += 1;
    }
    else if ([theStop position] == position) {
      [storage_ removeObjectAtIndex:index];
    }
  }
  [storage_ insertObject:[GTMCalculatedRangeStopPrivate stopWithObject:item position:position] 
                    atIndex:index];
}

- (BOOL)removeStopAtPosition:(float)position {
  unsigned int index = 0;
  BOOL foundStop = NO;
  NSEnumerator *theEnumerator = [storage_ objectEnumerator];
  GTMCalculatedRangeStopPrivate *theStop;
  while (nil != (theStop = [theEnumerator nextObject])) {
    if ([theStop position] == position) {
      break;
    } else {
       index += 1;
    }
  }
  if (nil != theStop) {
    [self removeStopAtIndex:index];
    foundStop = YES;
  }
  return foundStop;
}

- (void)removeStopAtIndex:(unsigned int)index {
  [storage_ removeObjectAtIndex:index];
}

- (unsigned int)stopCount {
  return [storage_ count];
}

- (id)stopAtIndex:(unsigned int)index position:(float*)outPosition {
  GTMCalculatedRangeStopPrivate *theStop = [storage_ objectAtIndex:index];
  if (nil != outPosition) {
    *outPosition = [theStop position];
  }
  return [theStop item];
}
  
- (id)valueAtPosition:(float)position {
  id theValue = nil;
  GTMCalculatedRangeStopPrivate *theStop;
  NSEnumerator *theEnumerator = [storage_ objectEnumerator];
  while (nil != (theStop = [theEnumerator nextObject])) {
    if ([theStop position] == position) {
      theValue = [theStop item];
      break;
    }
  }
  return theValue;
}

- (NSString *)description {
  return [storage_ description];
}
@end
