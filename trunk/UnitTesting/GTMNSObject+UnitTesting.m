//
//  GTMNSObject+UnitTesting.m
//  
//  An informal protocol for doing advanced unittesting with objects.
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

#include <Carbon/Carbon.h>
#include <mach-o/arch.h>

#import "GTMNSObject+UnitTesting.h"
#import "GTMNSWorkspace+Theme.h"
#import "GTMSystemVersion.h"

NSString *const GTMUnitTestingEncodedObjectNotification = @"GTMUnitTestingEncodedObjectNotification";
NSString *const GTMUnitTestingEncoderKey = @"GTMUnitTestingEncoderKey";

// This class exists so that we can locate our bundle using [NSBundle
// bundleForClass:]. We don't use [NSBundle mainBundle] because when we are
// being run as a unit test, we aren't the mainBundle
@interface GTMUnitTestingAdditionsBundleFinder : NSObject {
  // Nothing here
}
// or here
@end

@implementation GTMUnitTestingAdditionsBundleFinder 
// Nothing here. We're just interested in the name for finding our bundle.
@end

@interface NSObject (GTMUnitTestingAdditionsPrivate)
///  Find the path for a file named name.extension in your bundle.
//  Searches for the following:
//  "name.extension", 
//  "name.arch.extension", 
//  "name.arch.OSVersionMajor.extension"
//  "name.arch.OSVersionMajor.OSVersionMinor.extension"
//  "name.arch.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"
//  "name.arch.OSVersionMajor.extension"
//  "name.OSVersionMajor.arch.extension"
//  "name.OSVersionMajor.OSVersionMinor.arch.extension"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.arch.extension"
//  "name.OSVersionMajor.extension"
//  "name.OSVersionMajor.OSVersionMinor.extension"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"
//  Do not include the ".extension" extension on your name.
//
//  Args:
//    name: The name for the file you would like to find.
//    extension: the extension for the file you would like to find
//
//  Returns:
//    the path if the file exists in your bundle
//    or nil if no file is found
//
- (NSString *)pathForFileNamed:(NSString*)name extension:(NSString*)extension;
- (NSString *)saveToPathForFileNamed:(NSString*)name 
                           extension:(NSString*)extension;
@end

// This is a keyed coder for storing unit test state data. It is used only by
// the GTMUnitTestingAdditions category. Most of the work is done in
// encodeObject:forKey:.
@interface GTMUnitTestingKeyedCoder : NSCoder {
  NSMutableDictionary *dictionary_; // storage for data (STRONG)
}

//  get the data stored in coder.
//
//  Returns:
//    NSDictionary with currently stored data.
- (NSDictionary*)dictionary; 
@end

@implementation GTMUnitTestingKeyedCoder

//  Set up storage for coder. Stores type and version.
//  Version 1
// 
//  Returns:
//    self
- (id)init {
  self = [super init];
  if (self != nil) {
    dictionary_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dictionary_ setObject:@"GTMUnitTestingArchive" forKey:@"$GTMArchive"];
    
    // Version number can be changed here.
    [dictionary_ setObject:[NSNumber numberWithInt:1] forKey:@"$GTMVersion"];
  }
  return self;
}

// Standard dealloc
- (void)dealloc {
  [dictionary_ release];
  [super dealloc];
}

// Utility function for checking for a key value. We don't want duplicate keys
// in any of our dictionaries as we may be writing over data stored by previous
// objects.
//
//  Arguments:
//    key - key to check for in dictionary
- (void)checkForKey:(NSString*)key {
  NSAssert1(![dictionary_ objectForKey:key], @"Key already exists for %@", key);
}

// Key routine for the encoder. We store objects in our dictionary based on
// their key. As we encode objects we send out notifications to let other
// classes doing tests add their specific data to the base types. If we can't
// encode the object (it doesn't support unitTestEncodeState) and we don't get
// any info back from the notifier, we attempt to store it's description.
//
//  Arguments:
//    objv - object to be encoded
//    key - key to encode it with
//
- (void)encodeObject:(id)objv forKey:(NSString *)key {
  // Sanity checks
  if (!objv) return;
  [self checkForKey:key];
  
  // Set up a new dictionary for the current object
  NSMutableDictionary *curDictionary = dictionary_;
  dictionary_ = [[NSMutableDictionary alloc] initWithCapacity:0];
  
  // If objv responds to unitTestEncodeState get it to record
  // its data.
  if ([objv respondsToSelector:@selector(unitTestEncodeState:)]) {
    [objv unitTestEncodeState:self];
  }
  
  // We then send out a notification to let other folks
  // add data for this object
  NSDictionary *notificationDict = [NSDictionary dictionaryWithObject:self
                                                               forKey:GTMUnitTestingEncoderKey];
  [[NSNotificationCenter defaultCenter] postNotificationName:GTMUnitTestingEncodedObjectNotification
                                                      object:objv
                                                    userInfo:notificationDict];
  
  // If we got anything from the object, or from the notification, store it in
  // our dictionary. Otherwise store the description.
  if ([dictionary_ count] > 0) {
    [curDictionary setObject:dictionary_ forKey:key];
  } else {
    NSString *description = [objv description];
    // If description has a pointer value in it, we don't want to store it
    // as the pointer value can change from run to run
    if (description && [description rangeOfString:@"0x"].length == 0) {
      [curDictionary setObject:description forKey:key];
    } else {
      NSAssert1(NO, @"Unable to encode forKey: %@", key);
    }
  }
  [dictionary_ release];
  dictionary_ = curDictionary;
}

//  Basic encoding methods for POD types.
//
//  Arguments:
//    *v - value to encode
//    key - key to encode it in
- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key {
  [self checkForKey:key];
  [self encodeObject:(id)objv forKey:key];
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithBool:boolv] forKey:key];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithLong:intv] forKey:key];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithLongLong:intv] forKey:key];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithFloat:realv] forKey:key];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSNumber numberWithDouble:realv] forKey:key];
}

- (void)encodeBytes:(const uint8_t *)bytesp length:(unsigned)lenv forKey:(NSString *)key {
  [self checkForKey:key];
  [dictionary_ setObject:[NSData dataWithBytesNoCopy:(uint8_t*)bytesp length:lenv] forKey:key];
}

//  Get our storage back as an NSDictionary
//  
//  Returns:
//    NSDictionary containing our encoded info
-(NSDictionary*)dictionary {
  return [[dictionary_ retain] autorelease];
}

@end


@implementation NSObject (GTMUnitTestingAdditions)

// GTM_METHOD_CHECK(NSWorkspace, themeAppearance);
// GTM_METHOD_CHECK(NSWorkspace, themeScrollBarArrowStyle);

///  Find the path for a file named name.extension in your bundle.
//  Searches for the following:
//  "name.extension", 
//  "name.arch.extension", 
//  "name.arch.OSVersionMajor.extension"
//  "name.arch.OSVersionMajor.OSVersionMinor.extension"
//  "name.arch.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"
//  "name.arch.OSVersionMajor.extension"
//  "name.OSVersionMajor.arch.extension"
//  "name.OSVersionMajor.OSVersionMinor.arch.extension"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.arch.extension"
//  "name.OSVersionMajor.extension"
//  "name.OSVersionMajor.OSVersionMinor.extension"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"
//  Do not include the ".extension" extension on your name.
//
//  Args:
//    name: The name for the file you would like to find.
//    extension: the extension for the file you would like to find
//
//  Returns:
//    the path if the file exists in your bundle
//    or nil if no file is found
//
- (NSString *)pathForFileNamed:(NSString*)name extension:(NSString*)extension {
  NSString *thePath = nil;
  Class bundleClass = [GTMUnitTestingAdditionsBundleFinder class];
  NSBundle *myBundle = [NSBundle bundleForClass:bundleClass];
  NSAssert3(myBundle, @"Couldn't find bundle for class: %@ searching for file:%@.%@", 
            NSStringFromClass(bundleClass), name, extension);
  
  // Extensions
  NSString *extensions[2];
  const NXArchInfo *localInfo = NXGetLocalArchInfo();
  NSAssert(localInfo && localInfo->name, @"Couldn't get NXArchInfo");
  extensions[0] = [NSString stringWithUTF8String:localInfo->name];
  extensions[1] = @"";

  // System Version
  long major, minor, bugFix;
  [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
  NSString *systemVersions[4];
  systemVersions[0] = [NSString stringWithFormat:@".%d.%d.%d", major, minor, bugFix];
  systemVersions[1] = [NSString stringWithFormat:@".%d.%d", major, minor];
  systemVersions[2] = [NSString stringWithFormat:@".%d", major];
  systemVersions[3] = @"";
  
  // Note that we are searching for the most exact match first.
  for (int i = 0; !thePath && i < sizeof(extensions) / sizeof(*extensions); ++i) {
    for (int j = 0; !thePath && j < sizeof(systemVersions) / sizeof(*systemVersions); j++) {
      NSString *fullName = [NSString stringWithFormat:@"%@%@%@", name, extensions[i], systemVersions[j]];
      thePath = [myBundle pathForResource:fullName ofType:extension];
      if (thePath) break;
      fullName = [NSString stringWithFormat:@"%@%@%@", name, systemVersions[j], extensions[i]];
      thePath = [myBundle pathForResource:fullName ofType:extension];
    }
  }
  
  return thePath;
}  

- (NSString *)saveToPathForFileNamed:(NSString*)name 
                           extension:(NSString*)extension {
  NSString *newPath = nil;
  const NXArchInfo *localInfo = NXGetLocalArchInfo();
  NSAssert(localInfo && localInfo->name, @"Couldn't get NXArchInfo");
  long major, minor, bugFix;
  [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
  
  NSString *fullName = [NSString stringWithFormat:@"%@.%s.%d.%d.%d", 
                        name, localInfo->name, major, minor, bugFix];
  
  // Is this build under Pulse?
  if ([self isRunningUnderPulse]) {
    // Use the Pulse base directory
    newPath = [[[self pulseBaseDirectory] 
                stringByAppendingPathComponent:fullName]
               stringByAppendingPathExtension:extension];
  } else {
    // Developer build, use their home directory Desktop.
    newPath = [[[NSHomeDirectory() 
                 stringByAppendingPathComponent:@"Desktop"] 
                stringByAppendingPathComponent:fullName]
               stringByAppendingPathExtension:extension];
  }
  return newPath;
}
  
#pragma mark UnitTestImage

// Returns an image containing a representation of the object suitable for use
// in comparing against a master image. 
// NB this means that all colors should be device based, as colorsynced colors
// will be different on different devices.
//
//  Returns:
//    an image of the object
- (NSImage*)unitTestImage {
  // Must be overridden by subclasses
  [NSException raise:NSInternalInconsistencyException
              format:@"%@ must override -%@",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd)];

  return nil;  // appease the compiler
}

// Checks to see that system settings are valid for doing an image comparison.
// The main issue is that we make sure that we are set to using Blue Aqua as
// our appearance and that the scroll arrows are set correctly.
//
// Returns:
//  YES if we can do image comparisons for this object type.
- (BOOL)areSystemSettingsValidForDoingImage {
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  BOOL isGood = YES;
  
  if ([self needsAquaBlueAppearanceForDoingImage] &&
      ![[ws gtm_themeAppearance] isEqualToString:(NSString *)kThemeAppearanceAquaBlue]) {
    NSLog(@"Cannot do image test as appearance is not blue. "
          "Please set it in the Appearance System Preference.");
    isGood = NO;
  }
  
  if ([self needsScrollBarArrowsLowerRightForDoingImage] &&
      [ws gtm_themeScrollBarArrowStyle] != kThemeScrollBarArrowsLowerRight) {
    NSLog(@"Cannot do image test as scroll bar arrows are not together"
          "bottom right. Please set it in the Appearance System Preference.");
    isGood = NO;
  }
  
  return isGood;
}

// Defaults to the appearance not mattering, individual tests override.
- (BOOL)needsAquaBlueAppearanceForDoingImage {
  return NO;
}

// Defaults to the arrows not mattering, individual tests override.
- (BOOL)needsScrollBarArrowsLowerRightForDoingImage {
  return NO;
}

// Save the unitTestImage to a TIFF file with name |name| at
// ~/Desktop/|name|.tif. The TIFF will be compressed with LZW.
//
//  Note: When running under Pulse automation output is redirected to the
//  Pulse base directory.
//
//  Args:
//    name: The name for the TIFF file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToTIFFNamed:(NSString*)name {
  NSString *newPath = [self saveToPathForFileNamed:name extension:@"tif"];
  return [self saveToTIFFAt:newPath];
}

//  Save unitTestImage of |self| to a TIFF file at path |path|.
//  The TIFF will be compressed with LZW. 
//
//  Args:
//    name: The name for the TIFF file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToTIFFAt:(NSString*)path {
  if (!path) return NO;
  NSData *data = [self TIFFRepresentation];
  return [data writeToFile:path atomically:YES];
}

//  Compares unitTestImage of |self| to the TIFF located at |path|
//
//  Args:
//    path: the path to the TIFF file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithTIFFNamed:(NSString*)name {
  NSString *path = [self pathForTIFFNamed:name];
  return [self compareWithTIFFAt:path];
}

//  Compares unitTestImage of |self| to the TIFF located at |path|
//
//  Args:
//    path: the path to the TIFF file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithTIFFAt:(NSString*)path {
  BOOL answer = NO;
  NSData *fileData = [NSData dataWithContentsOfFile:path];
  if (fileData) {
    NSData *imageData = [self TIFFRepresentation];
    if (imageData) {
      NSBitmapImageRep *fileRep = [NSBitmapImageRep imageRepWithData:fileData];
      if (fileRep) {
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        if (imageRep) {
          NSSize fileSize = [fileRep size];
          NSSize imageSize = [imageRep size];
          if (NSEqualSizes(fileSize,imageSize)) {
            // if all the sizes are equal, run through the bytes and compare
            // them for equality.
            answer = YES;
            for (int row = 0; row < fileSize.height; row++) {
              for (int col = 0; col < fileSize.width && answer == YES; col++) {
                NSColor *imageColor = [imageRep colorAtX:col y:row];
                NSColor *fileColor = [fileRep colorAtX:col y:row];
                
                answer = [imageColor isEqual:fileColor];
              }
            } 
          }
        }
      }
    }
  }
  return answer;
}
  
//  Find the path for a TIFF by name in your bundle.
//  Do not include the ".tif" extension on your name.
//
//  Args:
//    name: The name for the TIFF file you would like to find.
//
//  Returns:
//    the path if the TIFF exists in your bundle
//    or nil if no TIFF to be found
//
- (NSString *)pathForTIFFNamed:(NSString*)name {
  return [self pathForFileNamed:name extension:@"tif"];
}

//  Gives us a LZW compressed representation of unitTestImage of |self|.
//
//  Returns:
//    a LZW compressed TIFF if successful
//    nil if failed
//
- (NSData *)TIFFRepresentation {
  NSImage *image = [self unitTestImage];
  // factor is ignored unless compression style is NSJPEGCompression
  return [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.0f];
}

#pragma mark UnitTestState

static NSString* const kGTMStateFileExtension = @"gtmUTState";

//  Save the encoded unit test state to a .gtmUTState file with name |name| at
//  ~/Desktop/|name|.gtmUTState.
//
//  Note: When running under Pulse automation output is redirected to the
//  Pulse base directory.
//
//  Args:
//    name: The name for the state file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToStateNamed:(NSString*)name {
  NSString *newPath = [self saveToPathForFileNamed:name 
                                         extension:kGTMStateFileExtension];
  return [self saveToStateAt:newPath];
}

//  Save encoded unit test state of |self| to a .gtmUTState file at path |path|.
//
//  Args:
//    name: The name for the state file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToStateAt:(NSString*)path {
  if (!path) return NO;
  NSDictionary *dictionary = [self stateRepresentation];
  return [dictionary writeToFile:path atomically:YES];
}

//  Compares encoded unit test state of |self| to the .gtmUTState named |name|
//
//  Args:
//    name: the name of the state file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithStateNamed:(NSString*)name {
  NSString *path = [self pathForStateNamed:name];
  return [self compareWithStateAt:path];

}

//  Compares encoded unit test state of |self| to the .gtmUTState located at
//  |path|
//
//  Args:
//    path: the path to the state file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithStateAt:(NSString*)path {
  NSDictionary *masterDict = [NSDictionary dictionaryWithContentsOfFile:path];
  NSAssert1(masterDict, @"Unable to create dictionary from %@", path);
  NSDictionary *selfDict = [self stateRepresentation];
  return [selfDict isEqualTo: masterDict];
}

//  Find the path for a state by name in your bundle.
//  Do not include the ".gtmUTState" extension.
//
//  Args:
//    name: The name for the state file you would like to find.
//
//  Returns:
//    the path if the state exists in your bundle
//    or nil if no state to be found
//
- (NSString *)pathForStateNamed:(NSString*)name {
  return [self pathForFileNamed:name extension:kGTMStateFileExtension];
}

//  Gives us the encoded unit test state |self|
//
//  Returns:
//    the encoded state if successful
//    nil if failed
//
- (NSDictionary *)stateRepresentation {
  NSDictionary *dictionary = nil;
  if ([self conformsToProtocol:@protocol(GTMUnitTestingEncoding)]) {
    id<GTMUnitTestingEncoding> encoder = (id<GTMUnitTestingEncoding>)self;
    GTMUnitTestingKeyedCoder *archiver = [[[GTMUnitTestingKeyedCoder alloc] init] autorelease];
    [encoder unitTestEncodeState:archiver];
    dictionary = [archiver dictionary];
  }
  return dictionary;
}

//  Encodes the state of an object in a manner suitable for comparing
//  against a master state file so we can determine whether the
//  object is in a suitable state. Encode data in the coder in the same
//  manner that you would encode data in any other Keyed NSCoder subclass.
//
//  Arguments:
//    inCoder - the coder to encode our state into
- (void)unitTestEncodeState:(NSCoder*)inCoder {
  // Currently does nothing, but all impls of unitTestEncodeState
  // should be calling [super unitTestEncodeState] as their first action.
}

- (NSMutableArray*)unitTestExposedBindingsToIgnore {
  NSMutableArray *array;
  if ([[self exposedBindings] containsObject:NSFontBinding]) {
    array = [NSMutableArray arrayWithObjects:
      NSFontBoldBinding, NSFontFamilyNameBinding, NSFontItalicBinding, 
      NSFontNameBinding, NSFontSizeBinding, nil];
  } else {
    array = [NSMutableArray array];
  }
  return array;
}

- (NSMutableDictionary*)unitTestExposedBindingsTestValues:(NSString*)binding {
  // Always test identity
  id value = [self valueForKey:binding];
  if (!value) {
    value = [NSNull null];
  }
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:value
                                                                 forKey:value];
  
  // Now some default test values for a variety of bindings to make
  // sure that we cover all the bases and save other people writing lots of
  // duplicate test code.
  
  // If anybody can think of more to add, please go nuts.
  if ([binding isEqualToString:NSAlignmentBinding]) {
    [dict setObjectAndKey:[NSNumber numberWithInt:NSLeftTextAlignment]];
    [dict setObjectAndKey:[NSNumber numberWithInt:NSRightTextAlignment]];
    [dict setObjectAndKey:[NSNumber numberWithInt:NSCenterTextAlignment]];
    [dict setObjectAndKey:[NSNumber numberWithInt:NSJustifiedTextAlignment]];
    NSNumber *natural = [NSNumber numberWithInt:NSNaturalTextAlignment];
    [dict setObjectAndKey:natural];
    [dict setObject:natural forKey:[NSNumber numberWithInt:500]];
    [dict setObject:natural forKey:[NSNumber numberWithInt:-1]];
  } else if ([binding isEqualToString:NSAlternateImageBinding] || 
             [binding isEqualToString:NSImageBinding] || 
             [binding isEqualToString:NSMixedStateImageBinding] || 
             [binding isEqualToString:NSOffStateImageBinding] ||
             [binding isEqualToString:NSOnStateImageBinding]) {
    // This handles all image bindings
    [dict setObjectAndKey:[NSImage imageNamed:@"NSApplicationIcon"]];
    [dict setObjectAndKey:[NSNull null]];
  } else if ([binding isEqualToString:NSAnimateBinding] || 
             [binding isEqualToString:NSDocumentEditedBinding] ||
             [binding isEqualToString:NSEditableBinding] ||
             [binding isEqualToString:NSEnabledBinding] ||
             [binding isEqualToString:NSHiddenBinding] ||
             [binding isEqualToString:NSVisibleBinding]) {
    // This handles all bool value bindings
    [dict setObjectAndKey:[NSNumber numberWithBool:YES]];
    [dict setObjectAndKey:[NSNumber numberWithBool:NO]];
  } else if ([binding isEqualToString:NSAlternateTitleBinding] ||
             [binding isEqualToString:NSHeaderTitleBinding] ||
             [binding isEqualToString:NSLabelBinding] ||
             [binding isEqualToString:NSRepresentedFilenameBinding] ||
             [binding isEqualToString:NSTitleBinding] ||
             [binding isEqualToString:NSToolTipBinding]) {
    // This handles all string value bindings
    [dict setObjectAndKey:@"happy"];
    [dict setObjectAndKey:[NSNull null]];
    // Test some non-ascii roman text
    char a_not_alpha[] = { 'A', 0xE2, 0x89, 0xA2, 0xCE, 0x91, '.', 0x00 };
    [dict setObjectAndKey:[NSString stringWithUTF8String:a_not_alpha]];
    // Test some korean
    char hangugo[] 
      = { 0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4, 0x00 };    
    [dict setObjectAndKey:[NSString stringWithUTF8String:hangugo]];
    // Test some japanese
    char nihongo[] 
      = { 0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E, 0x00 };
    [dict setObjectAndKey:[NSString stringWithUTF8String:nihongo]];
    // Test some arabic (right to left baby! ;-)
    char arabic[] = { 0xd9, 0x83, 0xd8, 0xa7, 0xd9, 0x83, 0xd8, 0xa7, 0x00 };
    [dict setObjectAndKey:[NSString stringWithUTF8String:arabic]];
  } else if ([binding isEqualToString:NSMaximumRecentsBinding] ||
              [binding isEqualToString:NSMaxValueBinding] ||
              [binding isEqualToString:NSMaxWidthBinding] ||
              [binding isEqualToString:NSMinValueBinding] ||
              [binding isEqualToString:NSMinWidthBinding] ||
              [binding isEqualToString:NSRecentSearchesBinding] || 
              [binding isEqualToString:NSRowHeightBinding] ||
              [binding isEqualToString:NSWidthBinding]) {
    // This handles all int value bindings
    [dict setObjectAndKey:[NSNumber numberWithInt:0]];
    [dict setObjectAndKey:[NSNumber numberWithInt:-1]];
    [dict setObjectAndKey:[NSNumber numberWithInt:INT16_MAX]];
    [dict setObjectAndKey:[NSNumber numberWithInt:INT16_MIN]];
  } else if ([binding isEqualToString:NSTextColorBinding]) {
    // This handles all color value bindings
    [dict setObjectAndKey:[NSColor colorWithDeviceWhite:1.0 alpha:1.0]];
    [dict setObjectAndKey:[NSColor colorWithDeviceWhite:1.0 alpha:0.0]];
    [dict setObjectAndKey:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
    [dict setObjectAndKey:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
    [dict setObjectAndKey:[NSColor colorWithDeviceCyan:0.25 magenta:0.25 yellow:0.25 black:0.25 alpha:0.25]];
  } else if ([binding isEqualToString:NSFontBinding]) {
    // This handles all font value bindings
    [dict setObjectAndKey:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]]];
    [dict setObjectAndKey:[NSFont toolTipsFontOfSize:[NSFont smallSystemFontSize]]];
    [dict setObjectAndKey:[NSFont labelFontOfSize:144.0]];
  }
  return dict;
}

@end

@implementation NSMutableDictionary (GTMUnitTestingAdditions)
// Sets an object and a key to the same value in a dictionary.
- (void)setObjectAndKey:(id)objectAndKey {
  [self setObject:objectAndKey forKey:objectAndKey];
}
@end


@implementation NSObject (GTMUnitTestingPulseAdditions)

- (BOOL)isRunningUnderPulse {
  
  if ([[[NSProcessInfo processInfo] environment] objectForKey:@"PULSE_BUILD_NUMBER"]) return YES;
  return NO;
  
}

- (NSString *)pulseBaseDirectory {
  
  return [[[NSProcessInfo processInfo] environment] objectForKey:@"PULSE_BASE_DIR"];
  
}

@end


