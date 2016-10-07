//
//  GTMUnitTestDevLog.m
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

#import "GTMUnitTestDevLog.h"

@interface GTMUnttestDevLogAssertionHandler : NSAssertionHandler
- (void)handleFailure:(NSString *)functionName
                 file:(NSString *)fileName
           lineNumber:(NSInteger)line
          description:(NSString *)format
            arguments:(va_list)argList NS_FORMAT_FUNCTION(4,0);
@end

@implementation GTMUnttestDevLogAssertionHandler
- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ... {
  NSString *call = [NSString stringWithFormat:@"[%@ %@]",
                    NSStringFromClass([object class]),
                    NSStringFromSelector(selector)];

  va_list argList;
  va_start(argList, format);
  [self handleFailure:call
             file:fileName
            lineNumber:line
          description:format
            arguments:argList];
  va_end(argList);
}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ... {
  va_list argList;
  va_start(argList, format);
  [self handleFailure:functionName
                 file:fileName
           lineNumber:line
          description:format
            arguments:argList];
  va_end(argList);
}

- (void)handleFailure:(NSString *)failure
                 file:(NSString *)fileName
           lineNumber:(NSInteger)line
          description:(NSString *)format
            arguments:(va_list)argList {
  NSString *descStr
       = [[[NSString alloc] initWithFormat:format arguments:argList] autorelease];

  // You need a format that will be useful in logs, but won't trip up Xcode or
  // any other build systems parsing of the output.
  NSString *outLog
      = [NSString stringWithFormat:@"RecordedNSAssert in %@ - %@ (%@:%ld)",
         failure, descStr, fileName, (long)line];
  // To avoid unused variable warning when _GTMDevLog is stripped.
  (void)outLog;
  _GTMDevLog(@"%@", outLog); // Don't want any percents in outLog honored
  [NSException raise:NSInternalInconsistencyException
              format:@"NSAssert raised"];
}
@end

@implementation GTMUnitTestDevLog

+ (void)enableTracking {

  NSMutableDictionary *threadDictionary
    = [[NSThread currentThread] threadDictionary];
  if ([threadDictionary objectForKey:@"NSAssertionHandler"] != nil) {
    NSLog(@"Warning: replacing NSAssertionHandler to capture assertions");
  }

  // Install an assertion handler to capture those.
  GTMUnttestDevLogAssertionHandler *handler =
    [[[GTMUnttestDevLogAssertionHandler alloc] init] autorelease];
  [threadDictionary setObject:handler forKey:@"NSAssertionHandler"];
}

+ (void)disableTracking {

  // Clear our assertion handler back out.
  NSMutableDictionary *threadDictionary
    = [[NSThread currentThread] threadDictionary];
  [threadDictionary removeObjectForKey:@"NSAssertionHandler"];
}

@end
