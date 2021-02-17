# GTM: Google Toolbox for Mac #

**Project site** <https://github.com/google/google-toolbox-for-mac><br>
**Discussion group** <http://groups.google.com/group/google-toolbox-for-mac>

# Google Toolbox for Mac #

A collection of source from different Google projects that may be of use to
developers working other iOS or OS X projects.

If you find a problem/bug or want a new feature to be included in the Google
Toolbox for Mac, please join the
[discussion group](http://groups.google.com/group/google-toolbox-for-mac)
or submit an
[issue](https://github.com/google/google-toolbox-for-mac/issues).

## Bazel Support

Google Toolbox for Mac can be consumed via Bazel, to do so add the following to your WORKSPACE File:

```WORKSPACE
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
