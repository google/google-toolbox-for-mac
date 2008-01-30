//
//  GTMNSEnumerator+Filter.m
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

#import "GTMNSEnumerator+Filter.h"

// a private subclass of NSEnumerator that does all the work.
// public interface just returns one of these.
// This top level class contains all the additional boilerplate. Specific
// behavior is in the subclasses.
@interface GTMEnumerator : NSEnumerator {
 @protected
  NSEnumerator *base_;  // STRONG
  SEL operation_; // either a predicate or a transform depending on context.
  id other_;  // STRONG, may be nil
}
- (id)nextObject;
- (BOOL)filterObject:(id)obj returning:(id *)resultp;
@end
@implementation GTMEnumerator
- (id)initWithBase:(NSEnumerator *)base
               sel:(SEL)filter
            object:(id)optionalOther {
  self = [super init];
  if (self) {

    // specializing a nil enumerator returns nil.
    if (nil == base) {
      [self release];
      return nil;
    }

    base_ = [base retain];
    operation_ = filter;
    other_ = [optionalOther retain];
  }
  return self;
}

// it is an error to call this initializer.
- (id)init {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)dealloc {
  [base_ release];
  [other_ release];
  [super dealloc];
}

- (id)nextObject {
  for (id obj = [base_ nextObject]; obj; obj = [base_ nextObject]) {
    id result = nil;
    if ([self filterObject:obj returning:&result]) {
      return result; 
    }
  }
  return nil;
}

// subclasses must override
- (BOOL)filterObject:(id)obj returning:(id *)resultp {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}
@end

// a transformer, for each item in the enumerator, returns a f(item).
@interface GTMEnumeratorTransformer : GTMEnumerator
- (BOOL)filterObject:(id)obj returning:(id *)resultp;
@end
@implementation GTMEnumeratorTransformer
- (BOOL)filterObject:(id)obj returning:(id *)resultp {
  *resultp = [obj performSelector:operation_ withObject:other_];
  return nil != *resultp;
}
@end

// a transformer, for each item in the enumerator, returns a f(item).
// a target transformer swaps the target and the argument.
@interface GTMEnumeratorTargetTransformer : GTMEnumerator
- (BOOL)filterObject:(id)obj returning:(id *)resultp;
@end
@implementation GTMEnumeratorTargetTransformer
- (BOOL)filterObject:(id)obj returning:(id *)resultp {
  *resultp = [other_ performSelector:operation_ withObject:obj];
  return nil != *resultp;
}
@end

// a filter, for each item in the enumerator, if(f(item)) { returns item. }
@interface GTMEnumeratorFilter : GTMEnumerator
- (BOOL)filterObject:(id)obj returning:(id *)resultp;
@end
@implementation GTMEnumeratorFilter
// We must take care here, since Intel leaves junk in high bytes of return register
// for predicates that return BOOL.
- (BOOL)filterObject:(id)obj returning:(id *)resultp {
  *resultp = obj;
  // intptr_t is an integer the same size as a pointer. <stdint.h>
  return (BOOL) (intptr_t) [obj performSelector:operation_ withObject:other_];
}
@end

// a target filter, for each item in the enumerator, if(f(item)) { returns item. }
// a target transformer swaps the target and the argument.
@interface GTMEnumeratorTargetFilter : GTMEnumerator
- (BOOL)filterObject:(id)obj returning:(id *)resultp;
@end
@implementation GTMEnumeratorTargetFilter
// We must take care here, since Intel leaves junk in high bytes of return register
// for predicates that return BOOL.
- (BOOL)filterObject:(id)obj returning:(id *)resultp {
  *resultp = obj;
  // intptr_t is an integer the same size as a pointer. <stdint.h>
  return (BOOL) (intptr_t) [other_ performSelector:operation_ withObject:obj];
}
@end

@implementation NSEnumerator (GTMEnumeratorFilterAdditions)

- (NSEnumerator *)gtm_filteredEnumeratorByMakingEachObjectPerformSelector:(SEL)selector
                                                               withObject:(id)argument {
  return [[[GTMEnumeratorFilter alloc] initWithBase:self
                                                sel:selector
                                             object:argument] autorelease];
}

- (NSEnumerator *)gtm_enumeratorByMakingEachObjectPerformSelector:(SEL)selector
                                                       withObject:(id)argument {
  return [[[GTMEnumeratorTransformer alloc] initWithBase:self
                                                     sel:selector
                                                  object:argument] autorelease];
}


- (NSEnumerator *)gtm_filteredEnumeratorByTarget:(id)target
                           performOnEachSelector:(SEL)selector {
  return [[[GTMEnumeratorTargetFilter alloc] initWithBase:self
                                                      sel:selector
                                                   object:target] autorelease];
}

- (NSEnumerator *)gtm_enumeratorByTarget:(id)target
                   performOnEachSelector:(SEL)selector {
  return [[[GTMEnumeratorTargetTransformer alloc] initWithBase:self
                                                           sel:selector
                                                        object:target] autorelease];
}

@end

