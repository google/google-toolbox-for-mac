/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTMARCMacros.h
//
// These macros enable code to compile in projects with and without
// automatic reference counting enabled.
//
// These macros are NOT needed for application code.
// They also are not needed for building libraries that are delivered
// as statically or dynamically linked files.
//
// The macros are for code that may be compiled both in targets with
// ARC enabled and in targets without ARC.
//

#ifndef GTM_REQUIRES_ARC
  #if defined(__clang__)
    #if __has_feature(objc_arc)
      #define GTM_REQUIRES_ARC 1
    #endif
  #endif
#endif

#if !defined(GTM_INLINE)
  #if (defined (__GNUC__) && (__GNUC__ == 4)) || defined (__clang__)
    #define GTM_INLINE static __inline__ __attribute__((always_inline))
  #else
    #define GTM_INLINE static __inline__
  #endif
#endif

//  Autorelease pool macro usage:
//
//  GTM_AUTORELEASEPOOL_START(pool) {
//    ...code...
//  } GTM_AUTORELEASEPOOL_END(pool);

// This inline function avoids the error "Expression result unused"
GTM_INLINE id GTM_UNCHANGED_RESULT(id x) { return x; }

#if GTM_REQUIRES_ARC
  // ARC builds
  #define GTM_RETAIN(x) GTM_UNCHANGED_RESULT(x)
  #define GTM_RELEASE(x) ((void) 0)
  #define GTM_AUTORELEASE(x) GTM_UNCHANGED_RESULT(x)
  #define GTM_RETAIN_AUTORELEASE(x) GTM_UNCHANGED_RESULT(x)
  #define GTM_UNSAFE_UNRETAINED __unsafe_unretained
  #define GTM_AUTORELEASING __autoreleasing
  #define GTM_STRONG __strong
  #define GTM_BRIDGE __bridge
  #define GTM_BRIDGING_RETAIN(x) CFBridgingRetain(x)
  #define GTM_BRIDGING_RELEASE(x) CFBridgingRelease(x)
  #define GTM_WEAK_PROPERTY weak
  #define GTM_SUPER_DEALLOC()
  #define GTM_AUTORELEASEPOOL_START(pool) @autoreleasepool
  #define GTM_AUTORELEASEPOOL_END(pool)
#else
  // MRR (non-ARC) builds
  #define GTM_RETAIN(x) [x retain]
  #define GTM_RELEASE(x) [x release]
  #define GTM_AUTORELEASE(x) [x autorelease]
  #define GTM_RETAIN_AUTORELEASE(x) [[x retain] autorelease]
  #define GTM_UNSAFE_UNRETAINED
  #define GTM_AUTORELEASING
  #define GTM_STRONG
  #define GTM_BRIDGE
  #define GTM_BRIDGING_RETAIN(x) (CFTypeRef)GTM_UNCHANGED_RESULT((id)(x ? CFRetain((CFTypeRef)x) : NULL))
  #define GTM_BRIDGING_RELEASE(cf) [(id)CFMakeCollectable(cf) autorelease]
  #define GTM_WEAK_PROPERTY assign
  #define GTM_SUPER_DEALLOC() [super dealloc]
  #define GTM_AUTORELEASEPOOL_START(pool) NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  #define GTM_AUTORELEASEPOOL_END(pool) [pool drain];
#endif
