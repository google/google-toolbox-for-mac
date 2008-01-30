//
//  GTMNSString+XML.m
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

#import "GTMNSString+XML.h"

typedef enum {
  kGMXMLCharModeEncodeQUOT  = 0,
  kGMXMLCharModeEncodeAMP   = 1,
  kGMXMLCharModeEncodeAPOS  = 2,
  kGMXMLCharModeEncodeLT    = 3,
  kGMXMLCharModeEncodeGT    = 4,
  kGMXMLCharModeValid       = 99,
  kGMXMLCharModeInvalid     = 100,
} GMXMLCharMode;

static NSString *gXMLEntityList[] = {
  // this must match the above order
  @"&quot;",
  @"&amp;",
  @"&apos;",
  @"&lt;",
  @"&gt;",
};

FOUNDATION_STATIC_INLINE GMXMLCharMode XMLModeForUnichar(unichar c) {

  // Per XML spec Section 2.2 Characters
  //   ( http://www.w3.org/TR/REC-xml/#charsets )
  //
  // 	Char	   ::=   	#x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] |
  //                      [#x10000-#x10FFFF]

  if (c <= 0xd7ff)  {
    if (c >= 0x20) {
      switch (c) {
        case 34:
          return kGMXMLCharModeEncodeQUOT;
        case 38:
          return kGMXMLCharModeEncodeAMP;
        case 39:
          return kGMXMLCharModeEncodeAPOS;
        case 60:
          return kGMXMLCharModeEncodeLT;
        case 62:
          return kGMXMLCharModeEncodeGT;
        default:
          return kGMXMLCharModeValid;
      }
    } else {
      if (c == '\n')
        return kGMXMLCharModeValid;
      if (c == '\r')
        return kGMXMLCharModeValid;
      if (c == '\t')
        return kGMXMLCharModeValid;
      return kGMXMLCharModeInvalid;
    }
  }

  if (c < 0xE000)
    return kGMXMLCharModeInvalid;

  if (c <= 0xFFFD)
    return kGMXMLCharModeValid;

  // unichar can't have the following values
  // if (c < 0x10000)
  //   return kGMXMLCharModeInvalid;
  // if (c <= 0x10FFFF)
  //   return kGMXMLCharModeValid;

  return kGMXMLCharModeInvalid;
} // XMLModeForUnichar

@implementation NSString (GTMNSStringXMLAdditions)

- (NSString *)gtm_stringByEscapingForXML {
  NSMutableString *finalString = [NSMutableString string];
  int length = [self length];
  require_quiet(length != 0, cantConvertAnything);

  // see if we can just use the interal version
  BOOL freeBuffer = NO;
  unichar *buffer = (unichar*)CFStringGetCharactersPtr((CFStringRef)self);
  if (!buffer) {
    // nope, alloc buffer and fetch the chars ourselves
    buffer = malloc(sizeof(unichar) * length);
    if (!buffer) return nil;
    freeBuffer = YES;
    [self getCharacters:buffer];
  }

  unichar *goodRun = buffer;
  int goodRunLength = 0;

  for (int i = 0; i < length; ++i) {

    GMXMLCharMode cMode = XMLModeForUnichar(buffer[i]);

    if (cMode == kGMXMLCharModeValid) {
      // goes as is
      goodRunLength += 1;
    } else {
      // it's something we have to encode or something invalid

      // start by adding what we already collected (if anything)
      if (goodRunLength) {
        CFStringRef goodRunString =
          CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault,
                                             goodRun, goodRunLength,
                                             kCFAllocatorNull);
        require_action(goodRunString != NULL, cantCreateString, finalString = nil);
        [finalString appendString:(NSString*)goodRunString];
        CFRelease(goodRunString);
        goodRunLength = 0;
      }

      // if it wasn't invalid, add the encoded version
      if (cMode != kGMXMLCharModeInvalid) {
        // add this encoded
        [finalString appendString:gXMLEntityList[cMode]];
      }

      // update goodRun to point to the next unichar
      goodRun = buffer + i + 1;
    }
  }

  // anything left to add?
  if (goodRunLength) {
    CFStringRef goodRunString =
      CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault,
                                         goodRun, goodRunLength,
                                         kCFAllocatorNull);
    require_action(goodRunString != NULL, cantCreateString2, finalString = nil);
    [finalString appendString:(NSString*)goodRunString];
    CFRelease(goodRunString);
  }
cantCreateString:
cantCreateString2:
  if (freeBuffer)
    free(buffer);
cantConvertAnything:
  return finalString;
} // gtm_stringByEscapingForXML

@end
