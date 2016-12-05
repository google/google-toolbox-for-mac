//
//  GTMABAddressBookTest.m
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

#import "GTMSenTestCase.h"
#import "GTMABAddressBook.h"

#if GTM_IPHONE_SDK
#import "UIKit/UIKit.h"
#else
#import <AppKit/AppKit.h>
#endif  // GTM_IPHONE_SDK

static NSString *const kGTMABTestFirstName = @"GTMABAddressBookTestFirstName";
static NSString *const kGTMABTestLastName = @"GTMABAddressBookTestLastName";
static NSString *const kGTMABTestGroupName = @"GTMABAddressBookTestGroupName";

@interface GTMABAddressBookTest : GTMTestCase {
 @private
  GTMABAddressBook *book_;
}
@end


@implementation GTMABAddressBookTest

#if GTM_IPHONE_SDK

// On iOS we need to check if we have access to the Address Book before running any tests.
// See
// third_party/objective_c/google_toolbox_for_mac/UnitTesting/GTMIPhoneUnitTestMain.m
// for a way this can be provided via entitlements.

+ (void)setUp {
  [super setUp];
  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
  if(status != kABAuthorizationStatusAuthorized) {
    [NSException raise:NSInternalInconsistencyException format:@"Don't have Address Book Access"];
  }
}

#endif  // GTM_IPHONE_SDK

- (void)setUp {
  // Create a book forcing it out of it's autorelease pool.
  // I force it out of the release pool, so that we will see any errors
  // for it immediately at teardown, and it will be clear which release
  // caused us problems.
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  book_ = [[GTMABAddressBook addressBook] retain];
  [pool release];
  XCTAssertNotNil(book_);
  NSArray *people
    = [book_ peopleWithCompositeNameWithPrefix:kGTMABTestFirstName];
  GTMABPerson *person;
  for (person in people) {
    [book_ removeRecord:person];
  }
  NSArray *groups
    = [book_ groupsWithCompositeNameWithPrefix:kGTMABTestGroupName];
  GTMABGroup *group;
  for (group in groups) {
    [book_ removeRecord:group];
  }
  [book_ save];
}

- (void)tearDown {
  [book_ release];
}

- (void)testGenericAddressBook {
  XCTAssertEqualObjects([GTMABAddressBook localizedLabel:(NSString *)kABHomeLabel],
                        @"home");
  XCTAssertThrows([GTMABRecord recordWithRecord:nil]);
}

- (void)testAddingAndRemovingPerson {
  // Create a person
  GTMABPerson *person = [GTMABPerson personWithFirstName:kGTMABTestFirstName
                                                lastName:kGTMABTestLastName];
  XCTAssertNotNil(person);

  // Add person
  NSArray *people = [book_ people];
  XCTAssertFalse([people containsObject:person]);
  XCTAssertTrue([book_ addRecord:person]);
#if GTM_IPHONE_SDK && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_2)
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200638: ABAddressBookHasUnsavedChanges doesn't work
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([book_ hasUnsavedChanges]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([book_ hasUnsavedChanges]);
#endif  // GTM_IPHONE_SDK

  people = [book_ people];
  XCTAssertNotNil(people);
#if GTM_IPHONE_SDK
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200703: ABAddressBookAddRecord doesn't add an item to the people
  //                array until it's saved
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([people containsObject:person]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([people containsObject:person]);
#endif  // GTM_IPHONE_SDK

  // Save book_
  XCTAssertTrue([book_ save]);
  people = [book_ people];
  XCTAssertNotNil(people);
  XCTAssertTrue([people containsObject:person]);
  people = [book_ peopleWithCompositeNameWithPrefix:kGTMABTestFirstName];
  XCTAssertEqualObjects([people objectAtIndex:0], person);

  GTMABRecordID recordID = [person recordID];
  XCTAssertNotEqual(recordID, kGTMABRecordInvalidID);

  GTMABRecord *record = [book_ personForId:recordID];
  XCTAssertEqualObjects(record, person);

  // Remove person
  XCTAssertTrue([book_ removeRecord:person]);
  people = [book_ peopleWithCompositeNameWithPrefix:kGTMABTestFirstName];
  XCTAssertEqual([people count], (NSUInteger)0);

#if GTM_IPHONE_SDK && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_2)
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200638: ABAddressBookHasUnsavedChanges doesn't work
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([book_ hasUnsavedChanges]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([book_ hasUnsavedChanges]);
#endif  // GTM_IPHONE_SDK
  people = [book_ people];
  XCTAssertFalse([people containsObject:person]);

  // Save Book
  XCTAssertTrue([book_ save]);
  people = [book_ people];
  XCTAssertFalse([book_ hasUnsavedChanges]);
  XCTAssertFalse([people containsObject:person]);
  record = [book_ personForId:recordID];
  XCTAssertNil(record);

  // Bogus data
  XCTAssertFalse([book_ addRecord:nil]);
  XCTAssertFalse([book_ removeRecord:nil]);

  XCTAssertNotNULL([book_ addressBookRef]);

}

- (void)testAddingAndRemovingGroup {
  // Create a group
  GTMABGroup *group = [GTMABGroup groupNamed:kGTMABTestGroupName];
  XCTAssertNotNil(group);

  // Add group
  NSArray *groups = [book_ groups];
  XCTAssertFalse([groups containsObject:group]);
  XCTAssertTrue([book_ addRecord:group]);
#if GTM_IPHONE_SDK && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_2)
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200638: ABAddressBookHasUnsavedChanges doesn't work
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([book_ hasUnsavedChanges]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([book_ hasUnsavedChanges]);
#endif  // GTM_IPHONE_SDK

  groups = [book_ groups];
  XCTAssertNotNil(groups);
#if GTM_IPHONE_SDK
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200703: ABAddressBookAddRecord doesn't add an item to the groups
  //                array until it's saved
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([groups containsObject:group]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([groups containsObject:group]);
#endif  // GTM_IPHONE_SDK

  // Save book_
  XCTAssertTrue([book_ save]);
  groups = [book_ groups];
  XCTAssertNotNil(groups);
  XCTAssertTrue([groups containsObject:group]);
  groups = [book_ groupsWithCompositeNameWithPrefix:kGTMABTestGroupName];
  XCTAssertEqualObjects([groups objectAtIndex:0], group);

  GTMABRecordID recordID = [group recordID];
  XCTAssertNotEqual(recordID, kGTMABRecordInvalidID);

  GTMABRecord *record = [book_ groupForId:recordID];
  XCTAssertEqualObjects(record, group);

  // Remove group
  XCTAssertTrue([book_ removeRecord:group]);

#if GTM_IPHONE_SDK && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_2)
  // Normally this next line would be XCTAssertTrue, however due to
  // Radar 6200638: ABAddressBookHasUnsavedChanges doesn't work
  // We will check to make sure it stays broken ;-)
  XCTAssertFalse([book_ hasUnsavedChanges]);
#else  // GTM_IPHONE_SDK
  XCTAssertTrue([book_ hasUnsavedChanges]);
#endif  // GTM_IPHONE_SDK
  groups = [book_ groups];
  XCTAssertFalse([groups containsObject:group]);

  // Save Book
  XCTAssertTrue([book_ save]);
  groups = [book_ groups];
  XCTAssertFalse([book_ hasUnsavedChanges]);
  XCTAssertFalse([groups containsObject:group]);
  groups = [book_ groupsWithCompositeNameWithPrefix:kGTMABTestGroupName];
  XCTAssertEqual([groups count], (NSUInteger)0);
  record = [book_ groupForId:recordID];
  XCTAssertNil(record);
}

- (void)testPerson {
  GTMABPerson *person = [[[GTMABPerson alloc] initWithRecord:nil] autorelease];
  XCTAssertNil(person);
  person = [GTMABPerson personWithFirstName:kGTMABTestFirstName
                                   lastName:nil];
  XCTAssertNotNil(person);
  XCTAssertEqualObjects([person compositeName], kGTMABTestFirstName);
  NSString *firstName = [person valueForProperty:kGTMABPersonFirstNameProperty];
  XCTAssertEqualObjects(firstName, kGTMABTestFirstName);
  NSString *lastName = [person valueForProperty:kGTMABPersonLastNameProperty];
  XCTAssertNil(lastName);
  XCTAssertTrue([person removeValueForProperty:kGTMABPersonFirstNameProperty]);
  XCTAssertFalse([person removeValueForProperty:kGTMABPersonFirstNameProperty]);
  XCTAssertFalse([person removeValueForProperty:kGTMABPersonLastNameProperty]);
  XCTAssertFalse([person setValue:nil forProperty:kGTMABPersonFirstNameProperty]);
  XCTAssertFalse([person setValue:[NSNumber numberWithInt:1]
                      forProperty:kGTMABPersonFirstNameProperty]);
  XCTAssertFalse([person setValue:@"Bart"
                      forProperty:kGTMABPersonBirthdayProperty]);

  GTMABPropertyType property
    = [GTMABPerson typeOfProperty:kGTMABPersonLastNameProperty];
  XCTAssertEqual(property, (GTMABPropertyType)kGTMABStringPropertyType);

  NSString *string
    = [GTMABPerson localizedPropertyName:kGTMABPersonLastNameProperty];
  XCTAssertEqualObjects(string, @"Last");

  string = [GTMABPerson localizedPropertyName:kGTMABRecordInvalidID];
#if GTM_IPHONE_SDK
  XCTAssertEqualObjects(string, kGTMABUnknownPropertyName);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(string, kGTMABRecordInvalidID);
#endif  // GTM_IPHONE_SDK
  string = [person description];
  XCTAssertNotNil(string);

  GTMABPersonCompositeNameFormat format = [GTMABPerson compositeNameFormat];
  XCTAssertTrue(format == kABPersonCompositeNameFormatFirstNameFirst ||
                format == kABPersonCompositeNameFormatLastNameFirst);

  NSData *data = [person imageData];
  XCTAssertNil(data);
  XCTAssertTrue([person setImageData:nil]);
  data = [person imageData];
  XCTAssertNil(data);
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *phonePath = [bundle pathForResource:@"phone" ofType:@"png"];
  XCTAssertNotNil(phonePath);
  GTMABImage *image
    = [[[GTMABImage alloc] initWithContentsOfFile:phonePath] autorelease];
  XCTAssertNotNil(image);
#if GTM_IPHONE_SDK
  data = UIImagePNGRepresentation(image);
#else  // GTM_IPHONE_SDK
  data = [image TIFFRepresentation];
#endif  // GTM_IPHONE_SDK
  XCTAssertTrue([person setImageData:data]);
  NSData *data2 = [person imageData];
  XCTAssertEqualObjects(data, data2);
  XCTAssertTrue([person setImageData:nil]);
  data = [person imageData];
  XCTAssertNil(data);

  XCTAssertTrue([person setImage:image]);
  GTMABImage *image2 = [person image];
  XCTAssertNotNil(image2);
#if GTM_IPHONE_SDK
  XCTAssertEqualObjects(UIImagePNGRepresentation(image),
                        UIImagePNGRepresentation(image2));
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects([image TIFFRepresentation],
                        [image2 TIFFRepresentation]);
#endif  // GTM_IPHONE_SDK

  person = [GTMABPerson personWithFirstName:kGTMABTestFirstName
                                   lastName:kGTMABTestLastName];

  data = [NSData dataWithBytes:"a" length:1];
  XCTAssertFalse([person setImageData:data]);

  GTMABMutableMultiValue *value
    = [GTMABMutableMultiValue valueWithPropertyType:kGTMABStringPropertyType];
  XCTAssertNotNil(value);
  XCTAssertNotEqual([value addValue:@"222-222-2222"
                          withLabel:(CFStringRef)kABHomeLabel],
                    kGTMABMultiValueInvalidIdentifier);
  XCTAssertNotEqual([value addValue:@"333-333-3333"
                          withLabel:(CFStringRef)kABWorkLabel],
                    kGTMABMultiValueInvalidIdentifier);
  XCTAssertTrue([person setValue:value
                     forProperty:kGTMABPersonPhoneProperty]);
  id value2 = [person valueForProperty:kGTMABPersonPhoneProperty];
  XCTAssertNotNil(value2);
  XCTAssertEqualObjects(value, value2);
  XCTAssertEqual([value hash], [value2 hash]);
  XCTAssertNotEqual([person hash], (NSUInteger)0);
}

- (void)testGroup {
  GTMABGroup *group = [[[GTMABGroup alloc] initWithRecord:nil] autorelease];
  XCTAssertNil(group);
  group = [GTMABGroup groupNamed:kGTMABTestGroupName];
  XCTAssertNotNil(group);
  XCTAssertEqualObjects([group compositeName], kGTMABTestGroupName);
  NSString *name = [group valueForProperty:kABGroupNameProperty];
  XCTAssertEqualObjects(name, kGTMABTestGroupName);
  NSString *lastName = [group valueForProperty:kGTMABPersonLastNameProperty];
  XCTAssertNil(lastName);
  XCTAssertTrue([group removeValueForProperty:kABGroupNameProperty]);
  XCTAssertFalse([group removeValueForProperty:kABGroupNameProperty]);
  XCTAssertFalse([group removeValueForProperty:kGTMABPersonLastNameProperty]);
  XCTAssertFalse([group setValue:nil forProperty:kABGroupNameProperty]);
  XCTAssertFalse([group setValue:[NSNumber numberWithInt:1]
                     forProperty:kABGroupNameProperty]);
  XCTAssertFalse([group setValue:@"Bart"
                     forProperty:kGTMABPersonBirthdayProperty]);

  ABPropertyType property = [GTMABGroup typeOfProperty:kABGroupNameProperty];
  XCTAssertEqual(property, (ABPropertyType)kGTMABStringPropertyType);

  property = [GTMABGroup typeOfProperty:kGTMABPersonLastNameProperty];
  XCTAssertEqual(property, (ABPropertyType)kGTMABInvalidPropertyType);

  NSString *string = [GTMABGroup localizedPropertyName:kABGroupNameProperty];
  XCTAssertEqualObjects(string, @"Name");

  string = [GTMABGroup localizedPropertyName:kGTMABPersonLastNameProperty];
  XCTAssertEqualObjects(string, kGTMABUnknownPropertyName);

  string = [GTMABGroup localizedPropertyName:kGTMABRecordInvalidID];
  XCTAssertEqualObjects(string, kGTMABUnknownPropertyName);

  string = [group description];
  XCTAssertNotNil(string);

  // Adding and removing members
  group = [GTMABGroup groupNamed:kGTMABTestGroupName];
  NSArray *members = [group members];
  XCTAssertEqual([members count], (NSUInteger)0, @"Members: %@", members);

  XCTAssertFalse([group addMember:nil]);

  members = [group members];
  XCTAssertEqual([members count], (NSUInteger)0, @"Members: %@", members);

  GTMABPerson *person = [GTMABPerson personWithFirstName:kGTMABTestFirstName
                                                lastName:kGTMABTestLastName];
  XCTAssertNotNil(person);
  XCTAssertTrue([book_ addRecord:person]);
  XCTAssertTrue([book_ save]);
  XCTAssertTrue([book_ addRecord:group]);
  XCTAssertTrue([book_ save]);
  XCTAssertTrue([group addMember:person]);
  XCTAssertTrue([book_ save]);
  members = [group members];
  XCTAssertEqual([members count], (NSUInteger)1, @"Members: %@", members);
  XCTAssertTrue([group removeMember:person]);
  XCTAssertFalse([group removeMember:person]);
  XCTAssertFalse([group removeMember:nil]);
  XCTAssertTrue([book_ removeRecord:group]);
  XCTAssertTrue([book_ removeRecord:person]);
  XCTAssertTrue([book_ save]);
}


- (void)testMultiValues {
  XCTAssertThrows([[GTMABMultiValue alloc] init]);
  XCTAssertThrows([[GTMABMutableMultiValue alloc] init]);
  GTMABMultiValue *value = [[GTMABMultiValue alloc] initWithMultiValue:nil];
  XCTAssertNil(value);
  GTMABMutableMultiValue *mutValue
    = [GTMABMutableMultiValue valueWithPropertyType:kGTMABInvalidPropertyType];
  XCTAssertNil(mutValue);
  mutValue
    = [[[GTMABMutableMultiValue alloc]
        initWithMutableMultiValue:nil] autorelease];
  XCTAssertNil(mutValue);
  mutValue
    = [[[GTMABMutableMultiValue alloc]
        initWithMultiValue:nil] autorelease];
  XCTAssertNil(mutValue);
#if GTM_IPHONE_SDK
  // Only the IPhone version actually allows you to check types of a multivalue
  // before you stick anything in it
  const GTMABPropertyType types[] = {
    kGTMABStringPropertyType,
    kGTMABIntegerPropertyType,
    kGTMABRealPropertyType,
    kGTMABDateTimePropertyType,
    kGTMABDictionaryPropertyType,
    kGTMABMultiStringPropertyType,
    kGTMABMultiIntegerPropertyType,
    kGTMABMultiRealPropertyType,
    kGTMABMultiDateTimePropertyType,
    kGTMABMultiDictionaryPropertyType
  };
  for (size_t i = 0; i < sizeof(types) / sizeof(GTMABPropertyType); ++i) {
    mutValue = [GTMABMutableMultiValue valueWithPropertyType:types[i]];
    XCTAssertNotNil(mutValue);
    // Oddly the Apple APIs allow you to create a mutable multi value with
    // either a property type of kABFooPropertyType or kABMultiFooPropertyType
    // and apparently you get back basically the same thing. However if you
    // ask a type that you created with kABMultiFooPropertyType for it's type
    // it returns just kABFooPropertyType.
    XCTAssertEqual([mutValue propertyType],
                   (GTMABPropertyType)(types[i] & ~kABMultiValueMask));
  }
#endif  // GTM_IPHONE_SDK
  mutValue
    = [GTMABMutableMultiValue valueWithPropertyType:kGTMABStringPropertyType];
  XCTAssertNotNil(mutValue);
  value = [[mutValue copy] autorelease];
  XCTAssertEqualObjects([value class], [GTMABMultiValue class]);
  mutValue = [[value mutableCopy] autorelease];
  XCTAssertEqualObjects([mutValue class], [GTMABMutableMultiValue class]);
  XCTAssertEqual([mutValue count], (NSUInteger)0);
  XCTAssertNil([mutValue valueAtIndex:0]);
  XCTAssertNil([mutValue labelAtIndex:0]);
#if GTM_IPHONE_SDK
  XCTAssertEqual([mutValue identifierAtIndex:0],
                 kGTMABMultiValueInvalidIdentifier);
  XCTAssertEqual([mutValue propertyType],
                 (GTMABPropertyType)kGTMABStringPropertyType);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects([mutValue identifierAtIndex:0],
                        kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  GTMABMultiValueIdentifier ident
    = [mutValue addValue:nil withLabel:(CFStringRef)kABHomeLabel];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK

  ident = [mutValue addValue:@"val1"
                   withLabel:nil];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  ident = [mutValue insertValue:@"val1"
                      withLabel:nil
                        atIndex:0];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  ident = [mutValue insertValue:nil
                      withLabel:(CFStringRef)kABHomeLabel
                        atIndex:0];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  ident = [mutValue addValue:@"val1"
                   withLabel:(CFStringRef)kABHomeLabel];
#if GTM_IPHONE_SDK
  XCTAssertNotEqual(ident, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertNotEqualObjects(ident, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  GTMABMultiValueIdentifier identCheck = [mutValue identifierAtIndex:0];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident, identCheck);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident, identCheck);
#endif  // GTM_IPHONE_SDK
  NSUInteger idx = [mutValue indexForIdentifier:ident];
  XCTAssertEqual(idx, (NSUInteger)0);
  XCTAssertTrue([mutValue replaceLabelAtIndex:0
                                    withLabel:(CFStringRef)kABWorkLabel]);
  XCTAssertFalse([mutValue replaceLabelAtIndex:10
                                     withLabel:(CFStringRef)kABWorkLabel]);
  XCTAssertTrue([mutValue replaceValueAtIndex:0
                                    withValue:@"newVal1"]);
  XCTAssertFalse([mutValue replaceValueAtIndex:10
                                     withValue:@"newVal1"]);

  XCTAssertEqualObjects([mutValue valueForIdentifier:ident], @"newVal1");
  XCTAssertEqualObjects([mutValue labelForIdentifier:ident],
                        (NSString *)kABWorkLabel);

  GTMABMultiValueIdentifier ident2
    = [mutValue insertValue:@"val2"
                  withLabel:(CFStringRef)kABOtherLabel
                    atIndex:0];
  XCTAssertNotEqual(ident2, kGTMABMultiValueInvalidIdentifier);
  XCTAssertNotEqual(ident2, ident);
  GTMABMultiValueIdentifier ident3
    = [mutValue insertValue:@"val3"
                  withLabel:(CFStringRef)kGTMABPersonPhoneMainLabel
                    atIndex:10];
#if GTM_IPHONE_SDK
  XCTAssertEqual(ident3, kGTMABMultiValueInvalidIdentifier);
#else  // GTM_IPHONE_SDK
  XCTAssertEqualObjects(ident3, kGTMABMultiValueInvalidIdentifier);
#endif  // GTM_IPHONE_SDK
  NSUInteger idx3 = [mutValue indexForIdentifier:ident3];
  XCTAssertEqual(idx3, (NSUInteger)NSNotFound);
  XCTAssertTrue([mutValue removeValueAndLabelAtIndex:1]);
  XCTAssertFalse([mutValue removeValueAndLabelAtIndex:1]);

  NSUInteger idx4
    = [mutValue indexForIdentifier:kGTMABMultiValueInvalidIdentifier];
  XCTAssertEqual(idx4, (NSUInteger)NSNotFound);

  XCTAssertNotNULL([mutValue multiValueRef]);

  // Enumerator test
  mutValue
    = [GTMABMutableMultiValue valueWithPropertyType:kGTMABIntegerPropertyType];
  XCTAssertNotNil(mutValue);
  for (int i = 0; i < 100; i++) {
    NSString *label = [NSString stringWithFormat:@"label %d", i];
    NSNumber *val = [NSNumber numberWithInt:i];
    XCTAssertNotEqual([mutValue addValue:val
                               withLabel:(CFStringRef)label],
                      kGTMABMultiValueInvalidIdentifier);
  }
  int count = 0;
  NSString *label;
  for (label in [mutValue labelEnumerator]) {
    NSString *testLabel = [NSString stringWithFormat:@"label %d", count++];
    XCTAssertEqualObjects(label, testLabel);
  }
  count = 0;
  value = [[mutValue copy] autorelease];
  NSNumber *val;
  for (val in [value valueEnumerator]) {
    XCTAssertEqualObjects(val, [NSNumber numberWithInt:count++]);
  }

  // Test messing with the values while we're enumerating them
  NSEnumerator *labelEnum = [mutValue labelEnumerator];
  NSEnumerator *valueEnum = [mutValue valueEnumerator];
  XCTAssertNotNil(labelEnum);
  XCTAssertNotNil(valueEnum);
  XCTAssertNotNil([labelEnum nextObject]);
  XCTAssertNotNil([valueEnum nextObject]);
  XCTAssertTrue([mutValue removeValueAndLabelAtIndex:0]);
  XCTAssertThrows([labelEnum nextObject]);
  XCTAssertThrows([valueEnum nextObject]);

  // Test messing with the values while we're fast enumerating them
  // Should throw an exception on the second access.
   BOOL exceptionThrown = NO;
  // Start at one because we removed index 0 above.
  count = 1;
  @try {
    for (label in [mutValue labelEnumerator]) {
      NSString *testLabel = [NSString stringWithFormat:@"label %d", count++];
      XCTAssertEqualObjects(label, testLabel);
      XCTAssertTrue([mutValue removeValueAndLabelAtIndex:50]);
    }
  } @catch(NSException *e) {
    XCTAssertEqualObjects([e name], NSGenericException, @"Got %@ instead", e);
    XCTAssertEqual(count, 2,
                   @"Should have caught it on the second access");
    exceptionThrown = YES;
  }  // COV_NF_LINE - because we always catch, this brace doesn't get exec'd
  XCTAssertTrue(exceptionThrown, @"We should have thrown an exception"
               @" because the values under the enumerator were modified");

}

#if GTM_IPHONE_SDK

#if (!defined(__LP64__) || !__LP64__)
// This test does not work on LP64 because refcounts are magic and don't work the
// same as on i386.
- (void)testRadar6208390 {
  GTMABPropertyType types[] = {
    kGTMABStringPropertyType,
    kGTMABIntegerPropertyType,
    kGTMABRealPropertyType,
    kGTMABDateTimePropertyType,
    kGTMABDictionaryPropertyType
  };
  for (size_t j = 0; j < sizeof(types) / sizeof(ABPropertyType); ++j) {
    ABPropertyType type = types[j];
    ABMultiValueRef ref = ABMultiValueCreateMutable(type);
    XCTAssertNotNULL(ref);
    NSString *label = [[NSString alloc] initWithString:@"label"];
    XCTAssertNotNil(label);
    id val = nil;
    if (type == kGTMABDictionaryPropertyType) {
      val = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"1", nil];
    } else if (type == kGTMABStringPropertyType) {
      val = [[NSString alloc] initWithFormat:@"value %zu", j];
    } else if (type == kGTMABIntegerPropertyType
               || type == kGTMABRealPropertyType ) {
      val = [[NSNumber alloc] initWithInt:143];
    } else if (type == kGTMABDateTimePropertyType) {
      val = [[NSDate alloc] init];
    }
    XCTAssertNotNil(val, @"Testing type %d, %@", type, val);
    NSUInteger firstRetainCount = [val retainCount];
    XCTAssertNotEqual(firstRetainCount,
                      (NSUInteger)0,
                      @"Testing type %d, %@", type, val);

    GTMABMultiValueIdentifier identifier;
    XCTAssertTrue(ABMultiValueAddValueAndLabel(ref,
                                               val,
                                               (CFStringRef)label,
                                               &identifier),
                  @"Testing type %d, %@", type, val);
    NSUInteger secondRetainCount = [val retainCount];
    XCTAssertEqual(firstRetainCount + 1,
                   secondRetainCount,
                   @"Testing type %d, %@", type, val);
    [label release];
    [val release];
    NSUInteger thirdRetainCount = [val retainCount];
    XCTAssertEqual(firstRetainCount,
                   thirdRetainCount,
                   @"Testing type %d, %@", type, val);

    id oldVal = val;
    val = (id)ABMultiValueCopyValueAtIndex(ref, 0);
    NSUInteger fourthRetainCount = [val retainCount];

    // kABDictionaryPropertyTypes appear to do an actual copy, so the retain
    // count checking trick won't work. We only check the retain count if
    // we didn't get a new version.
    if (val == oldVal) {
      if (type == kGTMABIntegerPropertyType
          || type == kGTMABRealPropertyType) {
        // We are verifying that yes indeed 6208390 is still broken
        XCTAssertEqual(fourthRetainCount,
                       thirdRetainCount,
                       @"Testing type %d, %@. If you see this error it may "
                       @"be time to update the code to change retain behaviors"
                       @"with this os version", type, val);
      } else {
        XCTAssertEqual(fourthRetainCount,
                       thirdRetainCount + 1,
                       @"Testing type %d, %@", type, val);
        [val release];
      }
    } else {
      [val release];
    }
    CFRelease(ref);
  }
}

#endif  // (!defined(__LP64__) || !__LP64__)

// Globals used by testRadar6240394.
static GTMABPropertyID gGTMTestID;
static const GTMABPropertyID *gGTMTestIDPtr;

void __attribute__((constructor))SetUpIDForTestRadar6240394(void) {
  // These must be set up BEFORE ABAddressBookCreate is called.
  gGTMTestID = kGTMABPersonLastNameProperty;
  gGTMTestIDPtr = &kGTMABPersonLastNameProperty;
}

- (void)testRadar6240394 {
  // As of iPhone SDK 2.1, the property IDs aren't initialized until
  // ABAddressBookCreate is actually called. They will return zero until
  // then. Logged as radar 6240394.
  XCTAssertEqual(gGTMTestID, 0, @"If this isn't zero, Apple has fixed 6240394");
  (void)ABAddressBookCreate();
  XCTAssertEqual(*gGTMTestIDPtr, kGTMABPersonLastNameProperty,
                 @"If this doesn't work, something else has broken");
}

#endif  // GTM_IPHONE_SDK
@end
