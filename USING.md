# Using Google Toolbox for Mac (GTM)

The Google Toolbox for Mac (GTM) project provides a collection of classes/helpers
for writing code for Apple platforms.

## Adding the Library to a Project

### CocoaPods

If you are building from CocoaPods, just use the pod provided, `GoogleToolboxForMac`.

The podspec provides subspecs so you can depend on exactly what parts of GTM you want
to used.

For example, if you want to use the _GeometryUtils_, you'd just need to add:

```
pod 'GoogleToolboxForMac/GeometryUtils'
```

### Bazel

GTM can be consumed via Bazel, to do so add the following to your `WORKSPACE` file:

```WORKSPACE
# Make sure you've brought in rules_apple per their release snippet
# https://github.com/bazelbuild/rules_apple/releases

GTM_GIT_SHA = "SOME_SHA"
http_archive(
    name = "google_toolbox_for_mac",
    urls = [
        "https://github.com/google/google-toolbox-for-mac/archive/%s.zip" % GTM_GIT_SHA
    ],
    strip_prefix = "google-toolbox-for-mac-%s" % GTM_GIT_SHA
)

load(
    "@google_toolbox_for_mac//bazel_support:repositories.bzl",
    "google_toolbox_for_mac_rules_dependencies",
)

google_toolbox_for_mac_rules_dependencies()

```

Then you can depend on the different sub targets that you'd like to use.
