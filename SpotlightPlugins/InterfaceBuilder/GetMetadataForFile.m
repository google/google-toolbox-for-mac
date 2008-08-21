//
//  GetMetadataForFile.m
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

#import <Foundation/Foundation.h>
#import "GTMScriptRunner.h"
#import "GTMGarbageCollection.h"

static BOOL AddStringsToTextContent(NSSet *stringSet, 
                                    NSMutableDictionary *attributes) {
  BOOL wasGood = NO;
  if ([stringSet count]) {
    NSString *allStrings = [[stringSet allObjects] componentsJoinedByString:@"\n"];
    NSString *oldContent = [attributes objectForKey:(NSString*)kMDItemTextContent];
    if (oldContent) {
      allStrings = [NSString stringWithFormat:@"%@\n%@", allStrings, oldContent];
    }
    [attributes setObject:allStrings forKey:(NSString*)kMDItemTextContent];
    wasGood = YES;
  }
  return wasGood;
}

static BOOL ExtractClasses(NSDictionary *ibToolData,
                           NSMutableDictionary *attributes) {
  NSString *classesKey = @"com.apple.ibtool.document.classes";
  NSDictionary *classes = [ibToolData objectForKey:classesKey];
  NSMutableSet *classSet = [NSMutableSet set];
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
  NSArray *classPrefixesToIgnore 
    = [ud objectForKey:@"classPrefixesToIgnore"];
  if (!classPrefixesToIgnore) {
    classPrefixesToIgnore = [NSArray arrayWithObjects:
                             @"IB", 
                             @"FirstResponder", 
                             @"NS", 
                             @"Web", 
                             nil];
    [ud setObject:classPrefixesToIgnore forKey:@"classPrefixesToIgnore"];
    [ud synchronize];
  }
  NSDictionary *entry;
  NSEnumerator *entryEnum = [classes objectEnumerator];
  while ((entry = [entryEnum nextObject])) {
    NSString *classStr = [entry objectForKey:@"class"];
    if (classStr) {
      NSString *prefix;
      NSEnumerator *classPrefixesToIgnoreEnum 
        = [classPrefixesToIgnore objectEnumerator];
      while (classStr && (prefix = [classPrefixesToIgnoreEnum nextObject])) {
        if ([classStr hasPrefix:prefix]) {
          classStr = nil;
        }
      }
      if (classStr) {
        [classSet addObject:classStr];
      }
    }
  }
  return AddStringsToTextContent(classSet, attributes);
}

static BOOL ExtractLocalizableStrings(NSDictionary *ibToolData,
                                      NSMutableDictionary *attributes) {
  NSString *localStrKey = @"com.apple.ibtool.document.localizable-strings";
  NSDictionary *strings = [ibToolData objectForKey:localStrKey];
  NSMutableSet *stringSet = [NSMutableSet set];
  NSDictionary *entry;
  NSEnumerator *entryEnum = [strings objectEnumerator];
  while ((entry = [entryEnum nextObject])) {
    NSEnumerator *stringEnum = [entry objectEnumerator];
    NSString *string;
    while ((string = [stringEnum nextObject])) {
      [stringSet addObject:string];
    }
  }
  return AddStringsToTextContent(stringSet, attributes);
}

static BOOL ExtractConnections(NSDictionary *ibToolData,
                               NSMutableDictionary *attributes) {
  NSString *connectionsKey = @"com.apple.ibtool.document.connections";
  NSDictionary *connections = [ibToolData objectForKey:connectionsKey];
  NSMutableSet *connectionsSet = [NSMutableSet set];
  NSDictionary *entry;
  NSEnumerator *entryEnum = [connections objectEnumerator];
  while ((entry = [entryEnum nextObject])) {
    NSString *typeStr = [entry objectForKey:@"type"];
    NSString *value = nil;
    if (typeStr) {
      if ([typeStr isEqualToString:@"IBBindingConnection"]) {
        value = [entry objectForKey:@"keypath"];
      } else if ([typeStr isEqualToString:@"IBCocoaOutletConnection"] ||
                 [typeStr isEqualToString:@"IBCocoaActionConnection"]) {
        value = [entry objectForKey:@"label"];
      }
      if (value) {
        [connectionsSet addObject:value];
      }
    }
  }
  return AddStringsToTextContent(connectionsSet, attributes);
}

static BOOL ImportIBFile(NSMutableDictionary *attributes, 
                         NSString *pathToFile) {
  BOOL wasGood = NO;
  GTMScriptRunner *runner = [GTMScriptRunner runner];
  NSDictionary *environment 
    = [NSDictionary dictionaryWithObject:@"/usr/bin:/Developer/usr/bin"
                                  forKey:@"PATH"];
  [runner setEnvironment:environment];
  NSString *cmdString 
    = @"ibtool --classes --localizable-strings --connections \"%@\"";
  NSString *cmd = [NSString stringWithFormat:cmdString, pathToFile];
  NSString *dataString = [runner run:cmd];
  CFDataRef data 
    = (CFDataRef)[dataString dataUsingEncoding:NSUTF8StringEncoding];
  if (data) {
    NSDictionary *results 
      = GTMCFAutorelease(CFPropertyListCreateFromXMLData(NULL, 
                                                         data ,
                                                         kCFPropertyListImmutable,
                                                         NULL));
    if (results && [results isKindOfClass:[NSDictionary class]]) {
      wasGood = ExtractClasses(results, attributes);
      wasGood |= ExtractLocalizableStrings(results, attributes);
      wasGood |= ExtractConnections(results, attributes);
    }
  }
  return wasGood;
}

// Grabs all of the classes, localizable strings, bindings, outlets 
// and actions and sticks them into kMDItemTextContent.
Boolean GetMetadataForFile(void* interface, 
                           CFMutableDictionaryRef cfAttributes, 
                           CFStringRef contentTypeUTI,
                           CFStringRef cfPathToFile) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableDictionary *attributes = (NSMutableDictionary*)cfAttributes;
  NSString *pathToFile = (NSString*)cfPathToFile;
  BOOL wasGood = NO;
  if (UTTypeConformsTo(contentTypeUTI, 
                       CFSTR("com.apple.interfacebuilder.document"))
      || UTTypeConformsTo(contentTypeUTI, 
                          CFSTR("com.apple.interfacebuilder.document.cocoa"))
      || UTTypeConformsTo(contentTypeUTI, 
                          CFSTR("com.apple.interfacebuilder.document.carbon"))) {
    wasGood = ImportIBFile(attributes, pathToFile);
  }
  [pool release];
  return  wasGood == NO ? FALSE : TRUE;
}
