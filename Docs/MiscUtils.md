# Miscellaneous Utilities

## GTMDebugSelectorValidation

For objects that expect to call selectors on an anonymous object, for example a
delegate object which partially conforms to a informal protocol, we supply
`GTMAssertSelectorNilOrImplementedWithArguments` and
`GTMAssertSelectorNilOrImplementedWithReturnTypeAndArguments` in
GTMDebugSelectorValidation.h. When a delegate is assigned to your object, you
can use these macros on each of the methods that you expect the delegate to
implement to make sure that the selectors have the correct arguments/return
types. These are not compiled into release builds.

## GTMMethodCheck

When using categories, it can be very easy to forget to include the
implementation of a category. Let's say you had a class foo that depended on
method bar of class baz, and method bar was implemented as a member of a
category on baz. Xcode will happily link your program without you actually
having a definition for bar included in your project. The `GTM_METHOD_CHECK`
macro checks to sure baz has a definition just before main is called. This works
for both dynamic libraries, and executables.

Example of usage:

```Objective-C
@implementation foo
  GTM_METHOD_CHECK(baz, bar)
@end
```

Classes (or one of their superclasses) being checked must conform to the
NSObject protocol. We will check this, and spit out a warning if a class does
not conform to NSObject. `GTM_METHOD_CHECK` is defined in GTMMethodCheck.h and
requires you to link in GTMMethodCheck.m as well. None of this code is compiled
into release builds. See GTMNSAppleScript+Handler.m for examples of using
`GTM_METHOD_CHECK`.

## GTMTypeCasting

[GTMTypeCasting.h](https://github.com/google/google-toolbox-for-mac/blob/main/DebugUtils/GTMTypeCasting.h)
contains some macros for making down-casting safer in Objective C. They are
loosely based on the same cast types with similar names in C++. A typical usage
would look like this:

```Objective-C
 Bar* b = [[Bar alloc] init];
 Foo* a = GTM_STATIC_CAST(Foo, b);
```

Note that it's `GTM_STATIC_CAST(Foo, b)` and not `GTM_STATIC_CAST(Foo*, b)`.

`GTM_STATIC_CAST` runs only in debug mode, and will assert if and only if:
  * object is non nil
  * `[object isKindOfClass:[cls class]]` returns nil

otherwise it returns object.

`GTM_DYNAMIC_CAST` runs in both debug and release and will return nil if
  * object is nil
  * `[object isKindOfClass:[cls class]]` returns nil

otherwise it returns object.

Good places to use `GTM_STATIC_CAST` is anywhere that you may normally use a
straight C cast to change one Objective C type to another. Another less visible
place is when converting an `id` to a more specific Objective C type. A classic
place that this occurs is when getting the `object` from a notification.

```Objective-C
- (void)myNotificationHandler:(NSNotification *)notification {
  MyType *foo = GTM_STATIC_CAST(MyType, [notification object]);
  ...
}
```

This will help you quickly trap cases where the type of notification object has
changed.

## Compile Time Asserts

For checking things at compile time we have `_GTMCompileAssert`. This allows us
to verify assumptions about things that the compiler knows about at compile time
such as sizes of structures. Please use this whenever applicable.
`_GTMCompileAssert` is defined in GTMDefines.h and you can see examples of it's
use in GTMGeometryUtils.h.
