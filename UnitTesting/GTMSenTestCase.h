//
//  GTMSenTestCase.h
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

// Some extra test case macros that would have been convenient for SenTestingKit
// to provide. I didn't stick GTM in front of the Macro names, so that they would
// be easy to remember.

#import "GTMDefines.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-id-macro"

#define _XCExceptionFormatString @"throwing \"%@\""
#define _XCUnknownExceptionString @"throwing an unknown exception"

#pragma clang diagnostic pop

// Generates a failure when a1 != noErr
//  Args:
//    a1: should be either an OSErr or an OSStatus
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertNoErr
#define XCTAssertNoErr(a1, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    __typeof__(a1) _a1value = (a1); \
    if (_a1value != noErr) { \
      _failure = [NSString stringWithFormat:@"%d != noErr", (int)_a1value]; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": " _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"((%@) != noErr) failed%@", @#a1, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertNoErr

// Generates a failure when a1 != a2
//  Args:
//    a1: received value. Should be either an OSErr or an OSStatus
//    a2: expected value. Should be either an OSErr or an OSStatus
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertErr
#define XCTAssertErr(a1, a2, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    __typeof__(a1) _a1value = (a1); \
    __typeof__(a2) _a2value = (a2); \
    if (_a1value != _a2value) { \
      _failure = [NSString stringWithFormat:@"(%d) != (%d)", (int)_a1value, (int)_a2value]; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": " _XCUnknownExceptionString; \
  } \
  if (_failure) { \
     NSString *_expression = [NSString stringWithFormat:@"((%@) != (%@)) failed %@", @#a1, @#a2, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif // XCTAssertErr

// Generates a failure when a1 is NULL
//  Args:
//    a1: should be a pointer (use XCTAssertNotNil for an object)
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertNotNULL
#define XCTAssertNotNULL(a1, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    __typeof__(a1) _a1value = (a1); \
    if (_a1value == (__typeof__(a1))NULL) { \
      _failure = @""; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": " _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"((%@) != NULL) failed%@", @#a1, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertNotNULL

// Generates a failure when a1 is not NULL
//  Args:
//    a1: should be a pointer (use XCTAssertNil for an object)
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertNULL
#define XCTAssertNULL(a1, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    __typeof__(a1) _a1value = (a1); \
    if (_a1value != (__typeof__(a1))NULL) { \
      _failure = @""; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": " _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"((%@) == NULL) failed%@", @#a1, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertNULL

// Generates a failure when string a1 is not equal to string a2. This call
// differs from XCTAssertEqualObjects in that strings that are different in
// composition (precomposed vs decomposed) will compare equal if their final
// representation is equal.
// ex O + umlaut decomposed is the same as O + umlaut composed.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertEqualStrings
#define XCTAssertEqualStrings(a1, a2, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    NSString *_a1value = (a1); \
    NSString *_a2value = (a2); \
    NSComparisonResult _result; \
    if (![_a1value isKindOfClass:[NSString class]]) { \
      _failure = [NSString stringWithFormat:@"(%@) is not an NSString* (%@)", @#a1, [_a1value class]]; \
    } else if (![_a2value isKindOfClass:[NSString class]]) { \
      _failure = [NSString stringWithFormat:@"(%@) is not an NSString* (%@)", @#a2, [_a2value class]]; \
    } else if ((_result = [_a1value compare:_a2value]) != NSOrderedSame) { \
      _failure = [NSString stringWithFormat:@"(%@) vs (%@) == %ld", _a1value, _a2value, (long)_result]; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:_XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"([(%@) compare:(%@)] == NSOrderedSame) failed: %@", @#a1, @#a2, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertEqualStrings

// Generates a failure when string a1 is equal to string a2. This call
// differs from XCTAssertEqualObjects in that strings that are different in
// composition (precomposed vs decomposed) will compare equal if their final
// representation is equal.
// ex O + umlaut decomposed is the same as O + umlaut composed.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertNotEqualStrings
#define XCTAssertNotEqualStrings(a1, a2, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    NSString *_a1value = (a1); \
    NSString *_a2value = (a2); \
    NSComparisonResult _result; \
    if (![_a1value isKindOfClass:[NSString class]]) { \
      _failure = [NSString stringWithFormat:@"(%@) is not an NSString* (%@)", @#a1, [_a1value class]]; \
    } else if (![_a2value isKindOfClass:[NSString class]]) { \
      _failure = [NSString stringWithFormat:@"(%@) is not an NSString* (%@)", @#a2, [_a2value class]]; \
    } else if ((_result = [_a1value compare:_a2value]) == NSOrderedSame) { \
      _failure = [NSString stringWithFormat:@"(%@) vs (%@) == %ld", _a1value, _a2value, (long)_result]; \
    } \
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:_XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"([(%@) compare:(%@)] != NSOrderedSame) failed: %@", @#a1, @#a2, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertNotEqualStrings

// Generates a failure when c-string a1 is not equal to c-string a2.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertEqualCStrings
#define XCTAssertEqualCStrings(a1, a2, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    const char* _a1value = (a1); \
    const char* _a2value = (a2); \
    if (_a1value != _a2value && \
        (_a1value == NULL || _a2value == NULL || strcmp(_a1value, _a2value) != 0)) { \
      _failure = [NSString stringWithFormat:@"strcmp(\"%s\", \"%s\") != 0", _a1value, _a2value]; \
    }\
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": " _XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"((%@) vs. (%@) failed: %@", \
        GTM_NSSTRINGIFY(a1), GTM_NSSTRINGIFY(a2), _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertEqualCStrings

// Generates a failure when c-string a1 is equal to c-string a2.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#ifndef XCTAssertNotEqualCStrings
#define XCTAssertNotEqualCStrings(a1, a2, format...) \
({ \
  NSString *_failure = nil; \
  @try { \
    const char* _a1value = (a1); \
    const char* _a2value = (a2); \
    if (_a1value == _a2value || strcmp(_a1value, _a2value) == 0) { \
      failure = @""; \
    }\
  } \
  @catch (NSException *_exception) { \
    _failure = [NSString stringWithFormat:@": " _XCExceptionFormatString, [_exception reason]]; \
  } \
  @catch (...) { \
    _failure = @": "_XCUnknownExceptionString; \
  } \
  if (_failure) { \
    NSString *_expression = [NSString stringWithFormat:@"((%s) != (%s) failed%@", @#a1, @#a2, _failure]; \
    _XCTRegisterFailure(self, _expression, format); \
  } \
})
#endif  // XCTAssertNotEqualCStrings

/*!
 * @define XCTAssertAsserts(expression, ...)
 * Generates a failure when ((\a expression) does not assert.
 * If NS_BLOCK_ASSERTIONS is enabled, this test will always pass.
 * @param expression An expression.
 * @param ... An optional supplementary description of the failure. A literal NSString, optionally
              with string format specifiers. This parameter can be completely omitted.
 */
#ifndef NS_BLOCK_ASSERTIONS
	#define XCTAssertAsserts(expression, ...) \
		_XCTPrimitiveAssertThrowsSpecificNamed(self, expression, @#expression, NSException, \
																					 NSInternalInconsistencyException, __VA_ARGS__)
#else
	#define XCTAssertAsserts(expression, ...)
#endif

// All unittest cases in GTM should inherit from GTMTestCase.
@interface GTMTestCase : XCTestCase

// Returns YES if this is an abstract testCase class as opposed to a concrete
// testCase class that you want tests run against. SenTestCase is not designed
// out of the box to handle an abstract class hierarchy descending from it with
// some concrete subclasses.  In some cases we want all the "concrete"
// subclasses of an abstract subclass of SenTestCase to run a test, but we don't
// want that test to be run against an instance of an abstract subclass itself.
// By returning "YES" here, the tests defined by this class won't be run against
// an instance of this class. As an example class hierarchy:
//
//                                            FooExtensionTestCase
// GTMTestCase <- ExtensionAbstractTestCase <
//                                            BarExtensionTestCase
//
// So FooExtensionTestCase and BarExtensionTestCase inherit from
// ExtensionAbstractTestCase (and probably FooExtension and BarExtension inherit
// from a class named Extension). We want the tests in ExtensionAbstractTestCase
// to be run as part of FooExtensionTestCase and BarExtensionTestCase, but we
// don't want them run against ExtensionAbstractTestCase. The default
// implementation checks to see if the name of the class contains the word
// "AbstractTest" (case sensitive).
+ (BOOL)isAbstractTestCase;

@end

NS_ASSUME_NONNULL_END
