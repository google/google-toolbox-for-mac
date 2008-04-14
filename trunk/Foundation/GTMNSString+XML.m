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

#import "GTMDefines.h"
#import "GTMNSString+XML.h"
#import "GTMGarbageCollection.h"
#import "GTMNSString+Utilities.h"
#import "GTMMethodCheck.h"

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

FOUNDATION_STATIC_INLINE GMXMLCharMode XMLModeForUnichar(UniChar c) {

  // Per XML spec Section 2.2 Characters
  //   ( http://www.w3.org/TR/REC-xml/#charsets )
  //
  //   Char    ::=       #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] |
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

  // UniChar can't have the following values
  // if (c < 0x10000)
  //   return kGMXMLCharModeInvalid;
  // if (c <= 0x10FFFF)
  //   return kGMXMLCharModeValid;

  return kGMXMLCharModeInvalid;
} // XMLModeForUnichar


static NSString *AutoreleasedCloneForXML(NSString *src, BOOL escaping) {
  //
  // NOTE:
  // We don't use CFXMLCreateStringByEscapingEntities because it's busted in
  // 10.3 (http://lists.apple.com/archives/Cocoa-dev/2004/Nov/msg00059.html) and
  // it doesn't do anything about the chars that are actually invalid per the
  // xml spec.
  //
  
  // we can't use the CF call here because it leaves the invalid chars
  // in the string.
  int length = [src length];
  if (!length) {
    return nil;
  }
  
  NSMutableString *finalString = [NSMutableString string];
  const UniChar *buffer = [src gtm_UTF16StringWithLength:nil];
  _GTMDevAssert(buffer, @"couldn't alloc buffer");
  
  const UniChar *goodRun = buffer;
  int goodRunLength = 0;
  
  for (int i = 0; i < length; ++i) {
    
    GMXMLCharMode cMode = XMLModeForUnichar(buffer[i]);
    
    // valid chars go as is, and if we aren't doing entities, then
    // everything goes as is.
    if ((cMode == kGMXMLCharModeValid) ||
        (!escaping && (cMode != kGMXMLCharModeInvalid))) {
      // goes as is
      goodRunLength += 1;
    } else {
      // it's something we have to encode or something invalid
      
      // start by adding what we already collected (if anything)
      if (goodRunLength) {
        CFStringAppendCharacters((CFMutableStringRef)finalString, 
                                 goodRun, 
                                 goodRunLength);
        goodRunLength = 0;
      }
      
      // if it wasn't invalid, add the encoded version
      if (cMode != kGMXMLCharModeInvalid) {
        // add this encoded
        [finalString appendString:gXMLEntityList[cMode]];
      }
      
      // update goodRun to point to the next UniChar
      goodRun = buffer + i + 1;
    }
  }
  
  // anything left to add?
  if (goodRunLength) {
    CFStringAppendCharacters((CFMutableStringRef)finalString, 
                             goodRun, 
                             goodRunLength);
  }
  return finalString;
} // AutoreleasedCloneForXML

@implementation NSString (GTMNSStringXMLAdditions)
GTM_METHOD_CHECK(NSString, gtm_UTF16StringWithLength:);

- (NSString *)gtm_stringBySanitizingAndEscapingForXML {
  return AutoreleasedCloneForXML(self, YES);
} // gtm_stringBySanitizingAndEscapingForXML

- (NSString *)gtm_stringBySanitizingToXMLSpec {
  return AutoreleasedCloneForXML(self, NO);
} // gtm_stringBySanitizingToXMLSpec

@end
