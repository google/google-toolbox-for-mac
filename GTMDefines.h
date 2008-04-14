// 
// GTMDefines.h
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
 
// ============================================================================

// ----------------------------------------------------------------------------
// CPP symbols that can be overridden in a prefix to control how the toolbox
// is compiled.
// ----------------------------------------------------------------------------

// _GTMDevLog & _GTMDevAssert
//
// _GTMDevLog & _GTMDevAssert are meant to be a very lightweight shell for
// developer level errors.  This implementation simply macros to NSLog/NSAssert.
// It is not intended to be a general logging/reporting system.
//
// Please see http://code.google.com/p/google-toolbox-for-mac/wiki/DevLogNAssert
// for a little more background on the usage of these macros.
//
//    _GTMDevLog           log some error/problem in debug builds
//    _GTMDevAssert        assert if conditon isn't met w/in a method/function
//                           in all builds.
// 
// To replace this system, just provide different macro definitions in your
// prefix header.  Remember, any implementation you provide *must* be thread
// safe since this could be called by anything in what ever situtation it has
// been placed in.
// 

// We only define the simple macros if nothing else has defined this.
#ifndef _GTMDevLog

#ifdef DEBUG
 #define _GTMDevLog(...) NSLog(__VA_ARGS__)
#else
 #define _GTMDevLog(...) do { } while (0)
#endif

// we directly invoke the NSAssert handler so we can pass on the varargs
// (NSAssert doesn't have a macro we can use that takes varargs)
#if !defined(NS_BLOCK_ASSERTIONS)
#define _GTMDevAssert(condition, ...)                                    \
  do {                                                                   \
    if (!(condition)) {                                                  \
      [[NSAssertionHandler currentHandler]                               \
          handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__] \
                             file:[NSString stringWithCString:__FILE__]  \
                       lineNumber:__LINE__                               \
                      description:__VA_ARGS__];                          \
    }                                                                    \
  } while(0)
#else // !defined(NS_BLOCK_ASSERTIONS)
#define _GTMDevAssert(condition, ...) do { } while (0)
#endif // !defined(NS_BLOCK_ASSERTIONS)

#endif // _GTMDevLog

// ============================================================================

// ----------------------------------------------------------------------------
// CPP symbols defined based on the project settings so the GTM code has
// simple things to test against w/o scattering the knowledge of project
// setting through all the code.
// ----------------------------------------------------------------------------

// Provide a single constant CPP symbol that all of GTM uses for ifdefing
// iPhone code.
#include <TargetConditionals.h>
#if TARGET_OS_IPHONE // iPhone SDK
  // For iPhone specific stuff
  #define GTM_IPHONE_SDK 1
#else
  // For MacOS specific stuff
  #define GTM_MACOS_SDK 1
#endif

