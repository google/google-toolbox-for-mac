load("@rules_cc//cc:defs.bzl", "objc_library")

objc_library(
    name = "UnitTesting",
    hdrs = [
        "GTMFoundationUnitTestingUtilities.h",
        "GTMSenTestCase.h",
        "GTMTestTimer.h"
    ],
    non_arc_srcs = [
        "GTMFoundationUnitTestingUtilities.m",
        "GTMSenTestCase.m"
    ],
    deps = [
        "//:Defines",
        "//Foundation:Regex",
        "//Foundation:SystemVersion",
    ],
    sdk_frameworks = [
        "CoreGraphics",
        "QuartzCore"
    ]
)

objc_library(
    name = "UnitTestingAppLib",
    hdrs = [
        "GTMCodeCoverageApp.h",
        "GTMIPhoneUnitTestDelegate.h"
    ],
    non_arc_srcs = [
        "GTMIPhoneUnitTestDelegate.m"
    ],
    deps = [
        "//:Defines",
        ":UnitTesting"
    ]
)
