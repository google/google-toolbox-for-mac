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

#import <SenTestingKit/SenTestingKit.h>

// Generates a failure when a1 != noErr
//  Args:
//    a1: should be either an OSErr or an OSStatus
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNoErr(a1, description, ...) \
do { \
  @try {\
    OSStatus a1value = (a1); \
    if (a1value != noErr) { \
      NSString *_expression = [NSString stringWithFormat:@"Expected noErr, got %ld for (%s)", a1value, #a1]; \
      if (description) { \
        _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
      } \
      [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:_expression]]; \
    } \
  }\
  @catch (id anException) {\
    [self failWithException:[NSException failureInRaise:[NSString stringWithFormat:@"(%s) == noErr fails", #a1] \
                                              exception:anException \
                                                 inFile:[NSString stringWithUTF8String:__FILE__] \
                                                 atLine:__LINE__ \
                                        withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
  }\
} while(0)

// Generates a failure when a1 != a2
//  Args:
//    a1: received value. Should be either an OSErr or an OSStatus
//    a2: expected value. Should be either an OSErr or an OSStatus
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertErr(a1, a2, description, ...) \
do { \
  @try {\
    OSStatus a1value = (a1); \
    OSStatus a2value = (a2); \
    if (a1value != a2value) { \
      NSString *_expression = [NSString stringWithFormat:@"Expected %s(%ld) but got %ld for (%s)", #a2, a2value, a1value, #a1]; \
      if (description) { \
        _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
      } \
      [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:_expression]]; \
    } \
  }\
  @catch (id anException) {\
    [self failWithException:[NSException failureInRaise:[NSString stringWithFormat:@"(%s) == noErr fails", #a1] \
                                              exception:anException \
                                                 inFile:[NSString stringWithUTF8String:__FILE__] \
                                                 atLine:__LINE__ \
                                        withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
  }\
} while(0)


// Generates a failure when a1 is NULL
//  Args:
//    a1: should be a pointer (use STAssertNotNil for an object)
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNotNULL(a1, description, ...) \
do { \
  @try {\
    char* a1value = (char*)(a1); \
    if (a1value == NULL) { \
      NSString *_expression = [NSString stringWithFormat:@"(%s) != NULL", #a1]; \
      if (description) { \
        _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
      } \
      [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:_expression]]; \
    } \
  }\
  @catch (id anException) {\
    [self failWithException:[NSException failureInRaise:[NSString stringWithFormat:@"(%s) != NULL fails", #a1] \
                                              exception:anException \
                                                 inFile:[NSString stringWithUTF8String:__FILE__] \
                                                 atLine:__LINE__ \
                                        withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
  }\
} while(0)

// Generates a failure when a1 is not NULL
//  Args:
//    a1: should be a pointer (use STAssertNil for an object)
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNULL(a1, description, ...) \
do { \
  @try {\
    char* a1value = (char*)(a1); \
    if (a1value != NULL) { \
      NSString *_expression = [NSString stringWithFormat:@"(%s) == NULL", #a1]; \
      if (description) { \
        _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
      } \
      [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:_expression]]; \
    } \
  }\
  @catch (id anException) {\
    [self failWithException:[NSException failureInRaise:[NSString stringWithFormat:@"(%s) == NULL fails", #a1] \
                                              exception:anException \
                                                 inFile:[NSString stringWithUTF8String:__FILE__] \
                                                 atLine:__LINE__ \
                                        withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
  }\
} while(0)

// Generates a failure when a1 is unequal to a2. This test is for C scalars, 
// structs and unions.
//  Args:
//    a1: argument 1
//    a2: argument 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNotEquals(a1, a2, description, ...) \
do { \
    @try {\
		if (@encode(typeof(a1)) != @encode(typeof(a2))) { \
			[self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:[@"Type mismatch -- " stringByAppendingString:STComposeString(description, ##__VA_ARGS__)]]]; \
		} \
		else { \
			typeof(a1) a1value = (a1); \
			typeof(a2) a2value = (a2); \
			NSValue *a1encoded = [NSValue value:&a1value withObjCType:@encode(typeof(a1))]; \
			NSValue *a2encoded = [NSValue value:&a2value withObjCType:@encode(typeof(a2))]; \
			if ([a1encoded isEqualToValue:a2encoded]) { \
        NSString *_expression = [NSString stringWithFormat:@"(%s) != (%s)", #a1, #a2]; \
        if (description) { \
          _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
        } \
				[self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                    atLine:__LINE__ \
                                              withDescription:_expression]]; \
			} \
		} \
    } \
    @catch (id anException) {\
        [self failWithException:[NSException \
					failureInRaise:[NSString stringWithFormat:@"(%s) != (%s)", #a1, #a2] \
						   exception:anException \
							    inFile:[NSString stringWithUTF8String:__FILE__] \
							    atLine:__LINE__ \
         withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
} while(0)

// Generates a failure when a1 is equal to a2. This test is for objects.
//  Args:
//    a1: argument 1. object.
//    a2: argument 2. object.
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNotEqualObjects(a1, a2, desc, ...) \
do { \
  @try {\
    id a1value = (a1); \
    id a2value = (a2); \
    if ( (@encode(typeof(a1value)) == @encode(id)) && \
         (@encode(typeof(a2value)) == @encode(id)) && \
         ![(id)a1value isEqual:(id)a2value] ) continue; \
         NSString *_expression = [NSString stringWithFormat:@"%s('%@') != %s('%@')", #a1, [a1 description], #a2, [a2 description]]; \
         if (desc) { \
           _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(desc, ##__VA_ARGS__)]; \
         } \
         [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                     atLine:__LINE__ \
                                            withDescription:_expression]]; \
  }\
  @catch (id anException) {\
    [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
                                              exception:anException \
                                                 inFile:[NSString stringWithUTF8String:__FILE__] \
                                                 atLine:__LINE__ \
                                        withDescription:STComposeString(desc, ##__VA_ARGS__)]]; \
  }\
} while(0)

// Generates a failure when a1 is not 'op' to a2. This test is for C scalars. 
//  Args:
//    a1: argument 1
//    a2: argument 2
//    op: operation
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertOperation(a1, a2, op, description, ...) \
do { \
  @try {\
		if (@encode(typeof(a1)) != @encode(typeof(a2))) { \
			[self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                  atLine:__LINE__ \
                                         withDescription:[@"Type mismatch -- " stringByAppendingString:STComposeString(description, ##__VA_ARGS__)]]]; \
		} \
		else { \
			typeof(a1) a1value = (a1); \
			typeof(a2) a2value = (a2); \
			if (!(a1value op a2value)) { \
        double a1DoubleValue = a1value; \
        double a2DoubleValue = a2value; \
        NSString *_expression = [NSString stringWithFormat:@"%s (%lg) %s %s (%lg)", #a1, a1DoubleValue, #op, #a2, a2DoubleValue]; \
        if (description) { \
          _expression = [NSString stringWithFormat:@"%@: %@", _expression, STComposeString(description, ##__VA_ARGS__)]; \
        } \
				[self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                                                    atLine:__LINE__ \
                                              withDescription:_expression]]; \
			} \
		} \
  } \
  @catch (id anException) {\
      [self failWithException:[NSException \
        failureInRaise:[NSString stringWithFormat:@"(%s) %s (%s)", #a1, #op, #a2] \
             exception:anException \
                inFile:[NSString stringWithUTF8String:__FILE__] \
                atLine:__LINE__ \
       withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
  }\
} while(0)

// Generates a failure when a1 is not > a2. This test is for C scalars. 
//  Args:
//    a1: argument 1
//    a2: argument 2
//    op: operation
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertGreaterThan(a1, a2, description, ...) \
  STAssertOperation(a1, a2, >, description, ##__VA_ARGS__)

// Generates a failure when a1 is not >= a2. This test is for C scalars. 
//  Args:
//    a1: argument 1
//    a2: argument 2
//    op: operation
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertGreaterThanOrEqual(a1, a2, description, ...) \
  STAssertOperation(a1, a2, >=, description, ##__VA_ARGS__)

// Generates a failure when a1 is not < a2. This test is for C scalars. 
//  Args:
//    a1: argument 1
//    a2: argument 2
//    op: operation
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertLessThan(a1, a2, description, ...) \
  STAssertOperation(a1, a2, <, description, ##__VA_ARGS__)

// Generates a failure when a1 is not <= a2. This test is for C scalars. 
//  Args:
//    a1: argument 1
//    a2: argument 2
//    op: operation
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertLessThanOrEqual(a1, a2, description, ...) \
  STAssertOperation(a1, a2, <=, description, ##__VA_ARGS__)

// Generates a failure when string a1 is not equal to string a2. This call
// differs from STAssertEqualObjects in that strings that are different in
// composition (precomposed vs decomposed) will compare equal if their final
// representation is equal.
// ex O + umlaut decomposed is the same as O + umlaut composed.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertEqualStrings(a1, a2, description, ...) \
do { \
    @try {\
      id a1value = (a1); \
      id a2value = (a2); \
      if (a1value == a2value) continue; \
      if ([a1value isKindOfClass:[NSString class]] && \
          [a2value isKindOfClass:[NSString class]] && \
          [a1value compare:a2value options:0] == NSOrderedSame) continue; \
       [self failWithException:[NSException failureInEqualityBetweenObject: a1value \
                                                                 andObject: a2value \
                                                                    inFile: [NSString stringWithUTF8String:__FILE__] \
                                                                    atLine: __LINE__ \
                                                           withDescription: STComposeString(description, ##__VA_ARGS__)]]; \
    }\
    @catch (id anException) {\
      [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
                                                exception:anException \
                                                   inFile:[NSString stringWithUTF8String:__FILE__] \
                                                   atLine:__LINE__ \
                                          withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
  } while(0)

// Generates a failure when string a1 is equal to string a2. This call
// differs from STAssertEqualObjects in that strings that are different in
// composition (precomposed vs decomposed) will compare equal if their final
// representation is equal.
// ex O + umlaut decomposed is the same as O + umlaut composed.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNotEqualStrings(a1, a2, description, ...) \
do { \
    @try {\
      id a1value = (a1); \
      id a2value = (a2); \
      if ([a1value isKindOfClass:[NSString class]] && \
          [a2value isKindOfClass:[NSString class]] && \
          [a1value compare:a2value options:0] != NSOrderedSame) continue; \
       [self failWithException:[NSException failureInEqualityBetweenObject: a1value \
                                                                 andObject: a2value \
                                                                    inFile: [NSString stringWithUTF8String:__FILE__] \
                                                                    atLine: __LINE__ \
                                                           withDescription: STComposeString(description, ##__VA_ARGS__)]]; \
    }\
    @catch (id anException) {\
      [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
                                                exception:anException \
                                                   inFile:[NSString stringWithUTF8String:__FILE__] \
                                                   atLine:__LINE__ \
                                          withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
  } while(0)

// Generates a failure when c-string a1 is not equal to c-string a2.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertEqualCStrings(a1, a2, description, ...) \
do { \
    @try {\
      const char* a1value = (a1); \
      const char* a2value = (a2); \
      if (a1value == a2value) continue; \
      if (strcmp(a1value, a2value) == 0) continue; \
      [self failWithException:[NSException failureInEqualityBetweenObject: [NSString stringWithUTF8String:a1value] \
                                                                andObject: [NSString stringWithUTF8String:a2value] \
                                                                   inFile: [NSString stringWithUTF8String:__FILE__] \
                                                                   atLine: __LINE__ \
                                                          withDescription: STComposeString(description, ##__VA_ARGS__)]]; \
    }\
    @catch (id anException) {\
      [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
                                                exception:anException \
                                                   inFile:[NSString stringWithUTF8String:__FILE__] \
                                                   atLine:__LINE__ \
                                          withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
  } while(0)

// Generates a failure when c-string a1 is equal to c-string a2.
//  Args:
//    a1: string 1
//    a2: string 2
//    description: A format string as in the printf() function. Can be nil or
//                 an empty string but must be present.
//    ...: A variable number of arguments to the format string. Can be absent.
#define STAssertNotEqualCStrings(a1, a2, description, ...) \
do { \
    @try {\
      const char* a1value = (a1); \
      const char* a2value = (a2); \
      if (strcmp(a1value, a2value) != 0) continue; \
      [self failWithException:[NSException failureInEqualityBetweenObject: [NSString stringWithUTF8String:a1value] \
                                                                andObject: [NSString stringWithUTF8String:a2value] \
                                                                   inFile: [NSString stringWithUTF8String:__FILE__] \
                                                                   atLine: __LINE__ \
                                                          withDescription: STComposeString(description, ##__VA_ARGS__)]]; \
    }\
    @catch (id anException) {\
      [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
                                                exception:anException \
                                                   inFile:[NSString stringWithUTF8String:__FILE__] \
                                                   atLine:__LINE__ \
                                          withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
  } while(0)

