//
//  GTMNSObject+UnitTesting.h
//
//  Utilities for doing advanced unittesting with objects.
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

#include <Cocoa/Cocoa.h>

/// Fails when image of |a1| does not equal image in TIFF file named |a2|
//
//  Generates a failure when the unittest image of |a1| is not equal to the 
//  image stored in the TIFF file named |a2|, or |a2| does not exist in the 
//  executable code's bundle.
//  If |a2| does not exist in the executable code's bundle, we save a TIFF
//  representation of |a1| on the desktop with name |a2|. This can then be
//  included in the bundle as the master to test against.
//  If |a2| != |a1|, we save a TIFF representation of |a1| on the desktop
//  with name |a2|_Failed so that we can compare the two files to see what
//  has changed.
//  See pathForTIFFNamed to see how name is searched for.
//  Implemented as a macro to match the rest of the SenTest macros.
//
//  Args:
//    a1: The object to be checked. Must implement the -unitTestImage method.
//    a2: The name of the TIFF file to check against.
//        Do not include the extension
//    description: A format string as in the printf() function. 
//        Can be nil or an empty string but must be present. 
//    ...: A variable number of arguments to the format string. Can be absent.
//
#define GTMAssertObjectImageEqualToTIFFNamed(a1, a2, description, ...) \
do { \
  NSObject* a1Object = (a1); \
  NSString* a2String = (a2); \
  NSString *failString = nil; \
  BOOL isGood = [a1Object respondsToSelector:@selector(unitTestImage)]; \
  if (isGood) { \
    if (![a1Object areSystemSettingsValidForDoingImage]) { \
      break; \
    } \
    NSString *aPath = [a1Object pathForTIFFNamed:a2String]; \
    isGood = aPath != nil; \
    if (isGood) { \
      isGood = [a1Object compareWithTIFFAt:aPath]; \
    } \
    if (!isGood) { \
      if (aPath != nil) { \
        a2String = [a2String stringByAppendingString:@"_Failed"]; \
      } \
      BOOL aSaved = [a1Object saveToTIFFNamed:a2String]; \
      if (NO == aSaved) {\
        if (aPath == nil) { \
          failString = [NSString stringWithFormat:@"File %@ did not exist in bundle. Tried to save %@ to desktop and failed.", a2String, a2String]; \
        } else { \
          failString = [NSString stringWithFormat:@"Object image different than file %@. Tried to save to desktop as %@ and failed.", aPath, a2String]; \
        } \
      } else { \
        if (aPath == nil) { \
          failString = [NSString stringWithFormat:@"File %@ did not exist in bundle. Saved to ~/Desktop/%@", a2String, a2String]; \
        } else { \
          failString = [NSString stringWithFormat:@"Object image different than file %@. Saved image to desktop as %@.", aPath, a2String]; \
        } \
      } \
    } \
  } else { \
    failString = @"Object does not respond to -unitTestImage"; \
  } \
  if (!isGood) { \
    if (nil != description) { \
      STFail(@"%@: %@", STComposeString(description, ##__VA_ARGS__), failString); \
    } else { \
      STFail(@"%@", failString); \
    } \
  } \
} while(0)

/// Fails when state of |a1| does not equal state in file |a2|
//
//  Generates a failure when the unittest state of |a1| is not equal to the 
//  state stored in the state file named |a2|, or |a2| does not exist in the 
//  executable code's bundle.
//  If |a2| does not exist in the executable code's bundle, we save a state
//  representation of |a1| on the desktop with name |a2|. This can then be
//  included in the bundle as the master to test against.
//  If |a2| != |a1|, we save a state representation of |a1| on the desktop
//  with name |a2|_Failed so that we can compare the two files to see what
//  has changed.
//  Implemented as a macro to match the rest of the SenTest macros.
//
//  Args:
//    a1: The object to be checked. Must implement the -unitTestImage method.
//    a2: The name of the state file to check against.
//        Do not include the extension
//    description: A format string as in the printf() function. 
//        Can be nil or an empty string but must be present. 
//    ...: A variable number of arguments to the format string. Can be absent.
//
#define GTMAssertObjectStateEqualToStateNamed(a1, a2, description, ...) \
do { \
  NSObject* a1Object = (a1); \
  NSString* a2String = (a2); \
  NSString *failString = nil; \
  BOOL isGood = [a1Object respondsToSelector:@selector(unitTestEncodeState:)]; \
  if (isGood) { \
    NSString *aPath = [a1Object pathForStateNamed:a2String]; \
    isGood = aPath != nil; \
    if (isGood) { \
      isGood = [a1Object compareWithStateAt:aPath]; \
    } \
    if (!isGood) { \
      if (aPath != nil) { \
        a2String = [a2String stringByAppendingString:@"_Failed"]; \
      } \
      BOOL aSaved = [a1Object saveToStateNamed:a2String]; \
      if (NO == aSaved) {\
        if (aPath == nil) { \
          failString = [NSString stringWithFormat:@"File %@ did not exist in bundle. Tried to save %@ to desktop and failed.", a2String, a2String]; \
        } else { \
          failString = [NSString stringWithFormat:@"Object state different than file %@. Tried to save to desktop as %@ and failed.", aPath, a2String]; \
        } \
      } else { \
        if (aPath == nil) { \
          failString = [NSString stringWithFormat:@"File %@ did not exist in bundle. Saved to ~/Desktop/%@", a2String, a2String]; \
        } else { \
          failString = [NSString stringWithFormat:@"Object state different than file %@. Saved image to desktop as %@.", aPath, a2String]; \
        } \
      } \
    } \
  } else { \
    failString = @"Object does not respond to -unitTestEncodeState:"; \
  } \
  if (!isGood) { \
    if (nil != description) { \
      STFail(@"%@: %@", STComposeString(description, ##__VA_ARGS__), failString); \
    } else { \
      STFail(@"%@", failString); \
    } \
  } \
} while(0)

/// test both GTMAssertObjectImageEqualToTIFFNamed and GTMAssertObjectStateEqualToStateNamed
//
// Combines the above two macros into a single ubermacro for comparing
// both state and image. When only the best will do...
#define GTMAssertObjectEqualToStateAndImageNamed(a1, a2, description, ...) \
do { \
  GTMAssertObjectImageEqualToTIFFNamed(a1, a2, description, ##__VA_ARGS__); \
  GTMAssertObjectStateEqualToStateNamed(a1, a2, description, ##__VA_ARGS__); \
} while (0)

/// Tests the setters and getters for exposed bindings
// For objects that expose bindings, this tests them for you, saving you from
// having to write a whole pile of set/get test code if you add binding support.
// You will need to implement valueClassForBinding: for your bindings,
// and you may possibly want to implement unitTestExposedBindingsToIgnore
// and unitTestExposedBindingsTestValues. See descriptions of those
// methods below for details.
//  Implemented as a macro to match the rest of the SenTest macros.
//
//  Args:
//    a1: The object to be checked.
//    description: A format string as in the printf() function. 
//        Can be nil or an empty string but must be present. 
//    ...: A variable number of arguments to the format string. Can be absent.
//
#define GTMTestExposedBindings(a1, description, ...) \
do { \
  NSArray *bindings = [a1 exposedBindings]; \
  if (bindings) { \
    NSArray *bindingsToIgnore = [a1 unitTestExposedBindingsToIgnore]; \
    NSEnumerator *bindingsEnum = [bindings objectEnumerator]; \
    NSString *bindingKey; \
    while ((bindingKey = [bindingsEnum nextObject])) { \
      if (![bindingsToIgnore containsObject:bindingKey]) { \
        Class theClass = [a1 valueClassForBinding:bindingKey]; \
        STAssertNotNil(theClass, @"Should have valueClassForBinding %@", bindingKey); \
        NSDictionary *testValues = [a1 unitTestExposedBindingsTestValues:bindingKey]; \
        NSEnumerator *testEnum = [testValues keyEnumerator]; \
        id testValue; \
        while ((testValue = [testEnum nextObject])) { \
          [a1 setValue:testValue forKey:bindingKey]; \
          id value = [a1 valueForKey:bindingKey]; \
          STAssertEqualObjects([testValues objectForKey:testValue], value, description, ##__VA_ARGS__); \
        } \
      } \
    } \
  } \
} while(0)
    
/// \cond Protocols

// GTMUnitTestingEncoding protocol is for objects which need to save their
// "state" for using with the unit testing categories
@protocol GTMUnitTestingEncoding
//  Encodes the state of an object in a manner suitable for comparing
//  against a master state file so we can determine whether the
//  object is in a suitable state. Encode data in the coder in the same
//  manner that you would encode data in any other Keyed NSCoder subclass.
//
//  Arguments:
//    inCoder - the coder to encode our state into
- (void)unitTestEncodeState:(NSCoder*)inCoder;
@end

/// Category for saving and comparing object state and image for unit tests
//
//  The GTMUnitTestAdditions category gives object the ability to store their
//  state for use in unittesting in two different manners.
// 1) Objects can elect to save their "image" as a TIFF that we can compare at
// runtime to a TIFF on file to make sure that the representation hasn't
// changed. All views and Windows can save their image. In the case of Windows,
// they are "bluescreened" so that any transparent areas can be compared between
// machines. For this to work, the appearance must be set to "Aqua blue" In the
// case of NSWindows and NSScreens, we do a screen capture operation to capture
// their image. In these cases, font smoothing settings must be set consistently
// across machines. The current standard is
//  Font Smoothing Style: Standard - Best For CRT
//  Turn Off Text Smoothing For Font Sizes: 8 And Smaller
// If you do not have these settings, any unit tests depending on them will not
// be executed, and a warning will be logged.
// Also, we need to be careful about avoiding ColorSync. In most cases the
// unittesting system handles this for you. If you are running into troubles
// make sure that you are using device colors, and not calibrated colors
// wherever you are doing drawing.
// 2) Objects can elect to save their "state". State is the attributes that we
// want to verify when running unit tests. Applications, Windows, Views,
// Controls and Cells currently return a variety of state information. If you
// want to customize the state information that a particular object returns, you
// can do it via the GTMUnitTestingEncodedObjectNotification. Items that have
// delegates (Applications/Windows) can also have their delegates return state
// information if appropriate via the unitTestEncoderDidEncode:inCoder: delegate
// method.
// To compare state/image in your unit tests, you can use the three macros above
// GTMAssertObjectStateEqualToStateNamed, GTMAssertObjectImageEqualToTIFFNamed and
// GTMAssertObjectEqualToStateAndImageNamed.
@interface NSObject (GTMUnitTestingAdditions) <GTMUnitTestingEncoding>
/// Returns an image containing a representation suitable for use in comparing against a master image. 
//
// NB this means that all colors should be
// device based, as colorsynced colors will be different on different devices.
//
//  Returns:
//    an image of the object
- (NSImage*)unitTestImage;

/// Checks to see that system settings are valid for doing an image comparison.
// The main issue is that we make sure that we are set to using Blue Aqua as
// our appearance.
// Instead of directly overriding this, a unit test can just use:
//   needsAquaBlueAppearanceForDoingImage
//   needsScrollBarArrowsLowerRightForDoingImage
// to enable those tests w/in this base implementation.
// The other issues are for NSScreen and NSWindow images as they are affected by
// the font smoothing settings in the system preferences. For things to work
// these settings must be set to:
//  Font Smoothing Style: Standard - Best For CRT
//  Turn Off Text Smoothing For Font Sizes: 8 And Smaller
//
// Returns:
//  YES if we can do image comparisons for this object type.
- (BOOL)areSystemSettingsValidForDoingImage;

/// Checks if this test needs the AquaBlue Appearance for doing the image comparison.
// If the test uses the appearance colors, this should be overriden to return
// YES (ie-default is no).  This provides a hook so the unittest can be skipped
// if the running user's settings aren't the "standard" for the UI unitttests.
//
// Returns:
//  YES if this test needs the AquaBlue Appearance.
- (BOOL)needsAquaBlueAppearanceForDoingImage;

/// Checks if this test needs the ScrollBarArrows LowerRight for doing the image comparison.
// If the test uses the scrollbar drawing, this should be overriden to return
// YES (ie-default is no).  This provides a hook so the unittest can be skipped
// if the running user's settings aren't the "standard" for the UI unitttests.
//
// Returns:
//  YES if this test needs the ScrollBarArrows LowerRight.
- (BOOL)needsScrollBarArrowsLowerRightForDoingImage;

/// Save the unitTestImage to a TIFF file with name |name| at ~/Desktop/|name|.tif.
// The TIFF will be compressed with LZW. 
//
//  Args:
//    name: The name for the TIFF file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToTIFFNamed:(NSString*)name;

/// Save unitTestImage of |self| to a TIFF file at path |path|. 
// The TIFF will be compressed with LZW. All non-drawn areas will be transparent.
//
//  Args:
//    name: The name for the TIFF file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToTIFFAt:(NSString*)path;

///  Compares unitTestImage of |self| to the TIFF located at |path|
//
//  Args:
//    path: the path to the TIFF file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithTIFFNamed:(NSString*)name;

///  Compares unitTestImage of |self| to the TIFF located at |path|
//
//  Args:
//    path: the path to the TIFF file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithTIFFAt:(NSString*)path;

///  Find the path for a TIFF by name in your bundle.
//  Searches for the following:
//  "name.tif", 
//  "name.arch.tif", 
//  "name.arch.OSVersionMajor.tif"
//  "name.arch.OSVersionMajor.OSVersionMinor.tif"
//  "name.arch.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.tif"
//  "name.arch.OSVersionMajor.tif"
//  "name.OSVersionMajor.arch.tif"
//  "name.OSVersionMajor.OSVersionMinor.arch.tif"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.arch.tif"
//  "name.OSVersionMajor.tif"
//  "name.OSVersionMajor.OSVersionMinor.tif"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.tif"
//  Do not include the ".tif" extension on your name.
//
//  Args:
//    name: The name for the TIFF file you would like to find.
//
//  Returns:
//    the path if the TIFF exists in your bundle
//    or nil if no TIFF to be found
//
- (NSString *)pathForTIFFNamed:(NSString*)name;


///  Gives us a LZW compressed representation of unitTestImage of |self|.
//
//  Returns:
//    a LZW compressed TIFF if successful
//    nil if failed
//
- (NSData *)TIFFRepresentation;


///  Save the encoded unit test state to a .gtmUTState file with name |name| at ~/Desktop/|name|.gtmUTState.
//
//  Args:
//    name: The name for the state file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToStateNamed:(NSString*)name;

///  Save encoded unit test state of |self| to a .gtmUTState file at path |path|.
//
//  Args:
//    name: The name for the state file you would like saved.
//
//  Returns:
//    YES if the file was successfully saved.
//
- (BOOL)saveToStateAt:(NSString*)path;

///  Compares encoded unit test state of |self| to the .gtmUTState named |name|
//
//  Args:
//    name: the name of the state file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithStateNamed:(NSString*)name;

/// Compares encoded unit test state of |self| to the .gtmUTState located at |path|.
//
//  Args:
//    path: the path to the state file you want to compare against.
//
//  Returns:
//    YES if they are equal, NO is they are not
//
- (BOOL)compareWithStateAt:(NSString*)path;

/// Find the path for a state by name in your bundle.
//  Searches for:
//  "name.gtmUTState", 
//  "name.arch.gtmUTState", 
//  "name.arch.OSVersionMajor.gtmUTState"
//  "name.arch.OSVersionMajor.OSVersionMinor.gtmUTState"
//  "name.arch.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.gtmUTState"
//  "name.arch.OSVersionMajor.gtmUTState"
//  "name.OSVersionMajor.arch.gtmUTState"
//  "name.OSVersionMajor.OSVersionMinor.arch.gtmUTState"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.arch.gtmUTState"
//  "name.OSVersionMajor.gtmUTState"
//  "name.OSVersionMajor.OSVersionMinor.gtmUTState"
//  "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.gtmUTState"
//  Do not include the ".gtmUTState" extension on your name.
//
//  Args:
//    name: The name for the state file you would like to find.
//
//  Returns:
//    the path if the state exists in your bundle
//    or nil if no state to be found
//
- (NSString *)pathForStateNamed:(NSString*)name;


///  Gives us the encoded unit test state for |self|
//
//  Returns:
//    the encoded state if successful
//    nil if failed
//
- (NSDictionary *)stateRepresentation;


/// Encodes the state of an object
//  Encodes the state of an object in a manner suitable for comparing
//  against a master state file so we can determine whether the
//  object is in a suitable state. Encode data in the coder in the same
//  manner that you would encode data in any other Keyed NSCoder subclass.
//
//  Arguments:
//    inCoder - the coder to encode our state into
- (void)unitTestEncodeState:(NSCoder*)inCoder;

/// Allows you to ignore certain bindings when running GTMTestExposedBindings
// If you have bindings you want to ignore, add them to the array returned
// by this method. The standard way to implement this would be:
// - (NSMutableArray*)unitTestExposedBindingsToIgnore {
//    NSMutableArray *array = [super unitTestExposedBindingsToIgnore];
//    [array addObject:@"bindingToIgnore1"];
//    ...
//    return array;
//  }
// The NSObject implementation by default will ignore NSFontBoldBinding,
// NSFontFamilyNameBinding, NSFontItalicBinding, NSFontNameBinding and 
// NSFontSizeBinding if your exposed bindings contains NSFontBinding because
// the NSFont*Bindings are NOT KVC/KVO compliant, and they just happen to work
// through what can only be described as magic :)
- (NSMutableArray*)unitTestExposedBindingsToIgnore;

/// Allows you to set up test values for your different bindings.
// if you have certain values you want to test against your bindings, add
// them to the dictionary returned by this method. The dictionary is a "value" key
// and an "expected return" object.
//  The standard way to implement this would be:
// - (NSMutableDictionary*)unitTestExposedBindingsTestValues:(NSString*)binding {
//    NSMutableDictionary *dict = [super unitTestExposedBindingsTestValues:binding];
//    if ([binding isEqualToString:@"myBinding"]) {
//      [dict setObject:[[[MySpecialBindingValueSet alloc] init] autorelease]
//               forKey:[[[MySpecialBindingValueGet alloc] init] autorelease]];
//      [dict setObjectAndKey:[[[MySpecialBindingValue alloc] init] autorelease]];
//      ...
//    else if ([binding isEqualToString:@"myBinding2"]) {
//      ...
//    }
//    return array;
//  }
// The NSObject implementation handles many of the default bindings, and
// gives you a reasonable set of test values to start.
// See the implementation for the current list of bindings, and values that we
// set for those bindings.
- (NSMutableDictionary*)unitTestExposedBindingsTestValues:(NSString*)binding;
@end

// Utility for simplifying unitTestExposedBindingsTestValues implementations
@interface NSMutableDictionary (GTMUnitTestingAdditions)
// Sets an object and a key to the same value in a dictionary.
- (void)setObjectAndKey:(id)objectAndKey;
@end

// Informal protocol for delegates that wanst to be able to add state info
// when state info is collected for their "owned" objects
@interface NSObject (GTMUnitTestingEncodingAdditions)
// Delegate function for unit test objects that have delegates. Delegates have
// the option of encoding more data into the coder to store their state for
// unittest usage.
- (void)unitTestEncoderDidEncode:(id)sender inCoder:(NSCoder*)inCoder;
@end

/// \endcond

// Whenever an object is encoded by the unit test encoder, it send out a
// notification so that objects who want to add data to the encoded objects unit
// test state can do so. The Coder will be in the userInfo dictionary for the
// notification under the GTMUnitTestingEncoderKey key.
extern NSString *const GTMUnitTestingEncodedObjectNotification;

// Key for finding the encoder in the userInfo dictionary for
// GTMUnitTestingEncodedObjectNotification notifications.
extern NSString *const GTMUnitTestingEncoderKey;


/// Support for Pulse automated builds
@interface NSObject (GTMUnitTestingPulseAdditions)

// Determine if the current unittest is running under Pulse
- (BOOL)isRunningUnderPulse;

// Get the current base directory for Pulse
- (NSString *)pulseBaseDirectory;

@end
