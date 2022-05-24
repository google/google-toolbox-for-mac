# Development of this Project

**Reminder:** Please see the
[CONTRIBUTING.md](https://github.com/google/google-api-objectivec-client-for-rest/blob/main/CONTRIBUTING.md)
file for how to contribute to this project.

## How?

Easiest is just to use the existing Xcode projects (remember to update both when
making changes for both platforms).

## About Log/Assert Usage w/in GTM

### Terminology

First, a little terminology authored/inspired by dmaclach:

**Log**

> A log is a debugging tool for reporting _interesting_ states to the developer
> running their code in a debugging mode. By interesting I mean states that the
> program can recover from, but doesn't necessarily expect. A log would be
> something that the implementor of the method feels is strange enough that it
> warrants notice by the developer, but not strange enough that the program
> cannot recover. As an example, several obj-c methods handle getting passed nil
> as a parameter. They don't generally expect nil, and will return an
> appropriate value (usually nil) but the fact that the client of the method is
> calling it with nil is probably a mistake, and something that should be
> avoided at a higher level. Logging is not a UI to report status back to the
> user, or a low-level way of communicating state to some other service. Logs
> can be turned on/off based on a compile time flag. Logs are purely a debugging
> tool, not a status reporting tool.

**Assert**

> An assert is something that a method requires to continue. If the assert
> fails, the function will (preferably) crash, or run in an undefined (most
> likely erroneous) state. The client calling the method has violated the
> contract with the method, and as such the method should not continue and has
> no recourse short of aborting. An assert fails in both debug and release mode.
> A perfectly valid implementation of an assert is to call log, and then abort.


**Reporting System/Logging System/Tracing System**

> Developers often want to keep track of what their application is doing, and
> will be quite application specific. These systems can be called "reporting",
> "logging" or "tracing" systems.  Exactly what they do/offer can be considered
> a _religious issue_ similar to exceptions vs error codes.  They may have
> levels and/or modules, support directing output to different sinks, and have
> runtime switches to control what is/isn't monitored.  In large applications,
> they have the ability to generate a lot of information.

### Log/Assert as far as GTM is concerned

Now, what this means to GTM:

One of the goals with GTM is to provide a collection of code that developers can
easily use without having to pick up stuff they don't need.  GTM uses
`_GTMDevLog` and `_GTMDevAssert` as internal calls to provide logs and
assertions; it is **_not_** meant to be a reporting system.  These two calls are
meant to be _extremely_ simple.  If a developer does nothing, `_GTMDevAssert`
will macro into `NSAssert` in all build styles. `_GTMDevLog` will macro to
`NSLog` in _Debug_ builds and will macro out of the code in _Release_ builds.

GTM uses `_GTMDevLog`/`_GTMDevAssert` as described above, to log two classes of
problems for developers.  No more, no less.  The intent that is any true errors
that would need to be presented to an end user should be returned from APIs via
`NSError` objects and/or other standard Cocoa practices.

GTM uses `_GTMDevLog`/`_GTMDevAssert` instead of directly calling
`NSLog`/`NSAssert` to allow a developer using GTM to remap these messages into
any reporting system _their_ application uses, by providing different
definitions of these two macros in a project's prefix header.

## Releasing

To update the version number and push a release:

1.  Examine what has changed; determine the appropriate new version number.

1.  Update the version number in the `.podspec` file.

    Submit the changes to the repo.

1.  Create a release on Github.

    Top left of the [project's release page](https://github.com/google/google-toolbox-for-mac/releases)
    is _Draft a new release_.

    The tag should be vX.Y.Z where the version number X.Y.Z _exactly_ matches
    the one you set in the podspec. (GoogleToolboxForMac has a `v` prefix on its
    tags.)

    For the description call out any major changes in the release. Usually a
    reference to the pull request and a short description is sufficient.

1.  Publish the CocoaPod.

    1.  Do a final sanity check on the podspec file:

        ```sh
        $ pod spec lint GoogleToolboxForMac.podspec
        ```

        If you used the update script above, this should pass without problems.

    1.  Publish the pod:

        ```sh
        $ pod trunk push GoogleToolboxForMac.podspec
        ```
