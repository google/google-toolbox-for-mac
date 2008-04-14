//
//  GTMSenTestCase.m
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

#import "GTMSenTestCase.h"

#if GTM_IPHONE_SDK

#import <stdarg.h>

@implementation NSException (GTMSenTestAdditions)

+ (NSException *)failureInFile:(NSString *)filename 
                        atLine:(int)lineNumber 
               withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"%@:%d: error: %@", filename, lineNumber, reason];
  return [NSException exceptionWithName:SenTestFailureException 
                                 reason:reason
                               userInfo:nil];
}

+ (NSException *)failureInCondition:(NSString *)condition 
                             isTrue:(BOOL)isTrue 
                             inFile:(NSString *)filename 
                             atLine:(int)lineNumber 
                    withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"condition '%@' is %s : %@", 
            condition, isTrue ? "TRUE" : "FALSE", reason];
  return [self failureInFile:filename atLine:lineNumber withDescription:reason];
}

+ (NSException *)failureInEqualityBetweenObject:(id)left
                                      andObject:(id)right
                                         inFile:(NSString *)filename
                                         atLine:(int)lineNumber
                                withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"%@ != %@ : %@",
            left, right, reason];
  return [self failureInFile:filename atLine:lineNumber withDescription:reason];
}

+ (NSException *)failureInEqualityBetweenValue:(NSValue *)left 
                                      andValue:(NSValue *)right 
                                  withAccuracy:(NSValue *)accuracy 
                                        inFile:(NSString *)filename 
                                        atLine:(int)lineNumber
                               withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"%@ != %@ with accuracy %@ : %@",
            left, right, accuracy, reason];
  return [self failureInFile:filename atLine:lineNumber withDescription:reason];  
}

+ (NSException *)failureInRaise:(NSString *)expression 
                         inFile:(NSString *)filename 
                         atLine:(int)lineNumber
                withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"failure in raise %@ : %@",
            expression, reason];
  return [self failureInFile:filename atLine:lineNumber withDescription:reason];  
}

+ (NSException *)failureInRaise:(NSString *)expression 
                      exception:(NSException *)exception 
                         inFile:(NSString *)filename 
                         atLine:(int)lineNumber 
                withDescription:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
  va_end(vl);
  reason = [NSString stringWithFormat:@"failure in raise %@ (%@) : %@",
            expression, exception, reason];
  return [self failureInFile:filename atLine:lineNumber withDescription:reason];  
}

@end

@implementation NSObject (GTMSenTestAdditions)
- (void)failWithException:(NSException*)exception {
  [exception raise];
}

@end

NSString *STComposeString(NSString *formatString, ...) {
  NSString *reason = @"";
  if (formatString) {
    va_list vl;
    va_start(vl, formatString);
    reason = [[[NSString alloc] initWithFormat:formatString arguments:vl] autorelease]; 
    va_end(vl);
  }
  return reason;
}

NSString * const SenTestFailureException = @"SenTestFailureException";

@implementation SenTestCase
- (void) setUp {
}

- (void) tearDown {
}
@end

#endif
