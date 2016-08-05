//
//  GTMMethodCheck.m
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

// Don't want any of this in release builds
#ifdef DEBUG
#import "GTMDefines.h"
#import "GTMMethodCheck.h"
#import "GTMObjC2Runtime.h"
#import <dlfcn.h>

void GTMMethodCheckMethodChecker(void) {
  // Run through all the classes looking for class methods that are
  // prefixed with xxGMMethodCheckMethod. If it finds one, it calls it.
  // See GTMMethodCheck.h to see what it does.
#if !defined(__has_feature) || !__has_feature(objc_arc)
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#else
  @autoreleasepool {
#endif
  // Since GTMMethodCheckMethodChecker is not exported, we should always find
  // the copy in our local image. This will give us access to our local image
  // in the methodCheckerInfo structure.
  Dl_info methodCheckerInfo;
  int foundMethodChecker = dladdr(GTMMethodCheckMethodChecker,
                                  &methodCheckerInfo);
  _GTMDevAssert(foundMethodChecker, @"GTMMethodCheckMethodChecker: Unable to "
                @"get dladdr for GTMMethodCheckMethodChecker");
  int numClasses = 0;
  int newNumClasses = objc_getClassList(NULL, 0);
  int i;
  Class *classes = NULL;
  while (numClasses < newNumClasses) {
    numClasses = newNumClasses;
    classes = (Class *)realloc(classes, sizeof(Class) * numClasses);
    _GTMDevAssert(classes, @"Unable to allocate memory for classes");
    newNumClasses = objc_getClassList(classes, numClasses);
  }
  for (i = 0; i < numClasses && classes; ++i) {
    Class cls = classes[i];
    const char *className = class_getName(cls);
    _GTMDevAssert(className, @"GTMMethodCheckMethodChecker: Unable to "
                  @"get className for class %d", i);
    // Since we are looking for a class method (+xxGMMethodCheckMethod...)
    // we need to query the isa pointer to see what methods it support, but
    // send the method (if it's supported) to the class itself.
    if (strcmp(className, "__ARCLite__") == 0) {
      // __ARCLite__ is "magic" and does not have a metaClass.
      continue;
    }
    Class metaClass = objc_getMetaClass(className);
    _GTMDevAssert(metaClass, @"GTMMethodCheckMethodChecker: Unable to "
                  @"get metaClass for %s", className);
    unsigned int count;
    Method *methods = class_copyMethodList(metaClass, &count);
    if (count == 0) {
      continue;
    }
    _GTMDevAssert(methods, @"GTMMethodCheckMethodChecker: Unable to "
                  @"get methods for class %s", className);

    unsigned int j;
    for (j = 0; j < count; ++j) {
      SEL selector = method_getName(methods[j]);
      _GTMDevAssert(selector, @"GTMMethodCheckMethodChecker: Unable to "
                    @"get selector for method %d of %s", j, className);
      const char *name = sel_getName(selector);
      _GTMDevAssert(selector, @"GTMMethodCheckMethodChecker: Unable to "
                    @"get name for method %d of %s", j, className);
      if (strstr(name, "xxGTMMethodCheckMethod") == name) {
        Dl_info methodInfo;
        IMP imp = method_getImplementation(methods[j]);
        _GTMDevAssert(selector, @"GTMMethodCheckMethodChecker: Unable to "
                      @"get IMP for method %s of %s", name, className);
        int foundMethod = dladdr(imp, &methodInfo);
        _GTMDevAssert(foundMethod, @"GTMMethodCheckMethodChecker: Unable to "
                      @"get dladdr for method %s of %s", name, className);

        // Check to make sure that the method we are checking comes from the
        // same image that we are in. We compare the address of the local
        // image (stored in |methodCheckerInfo| as noted above) with the
        // address of the image which implements the method we want to
        // check. If they match we continue. This does two things:
        // a) minimizes the amount of calls we make to the xxxGTMMethodCheck
        //    methods. They should only be called once.
        // b) prevents initializers for various classes being called too
        //    early
        if (methodCheckerInfo.dli_fbase == methodInfo.dli_fbase) {
          void (*func)(id, SEL) = (void *)imp;
          func(cls, selector);
        }
      }
    }
    free(methods);
  }
  free(classes);
#if !defined(__has_feature) || !__has_feature(objc_arc)
  [pool drain];
#else
  }  // @autoreleasepool
#endif
}

#endif  // DEBUG
