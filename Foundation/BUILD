load("@rules_cc//cc:defs.bzl", "objc_library")

exports_files([
    "GTMLocalizedString.h",
    "GTMLogger.h"
])

objc_library(
    name = "GeometryUtils",
    hdrs = [
        "GTMGeometryUtils.h",
    ],
    srcs = [
        "GTMGeometryUtils.m",
    ],
    deps = [
        "//:Defines"
    ],
    sdk_frameworks = [
        "CoreGraphics"
    ]
)

objc_library(
    name = "KVO",
    hdrs = [
        "GTMNSObject+KeyValueObserving.h",
    ],
    non_arc_srcs = [
        "GTMNSObject+KeyValueObserving.m",
    ],
    deps = [
        "//:Core",
        "//DebugUtils:DebugUtils"
    ],
    copts = ["-IDebugUtils"],
    sdk_frameworks = [
        "CoreGraphics"
    ]
)

objc_library(
    name = "Logger",
    hdrs = [
        "GTMLogger.h",
    ],
    non_arc_srcs = [
        "GTMLogger.m",
    ],
    deps = [
        "//:Defines"
    ]
)

objc_library(
    name = "Regex",
    hdrs = [
        "GTMRegex.h",
    ],
    non_arc_srcs = [
        "GTMRegex.m",
    ],
    deps = [
        "//:Defines"
    ],
    visibility = ["//visibility:public"]
)

objc_library(
    name = "StackTrace",
    hdrs = [
        "GTMStackTrace.h",
    ],
    non_arc_srcs = [
        "GTMStackTrace.m",
    ],
    deps = [
        "//:Defines"
    ]
)

objc_library(
    name = "StringEncoding",
    hdrs = [
        "GTMStringEncoding.h",
    ],
    non_arc_srcs = [
        "GTMStringEncoding.m",
    ],
    deps = [
        "//:Defines"
    ]
)

objc_library(
    name = "SystemVersion",
    hdrs = [
        "GTMSystemVersion.h",
    ],
    non_arc_srcs = [
        "GTMSystemVersion.m",
    ],
    deps = [
        "//:Defines"
    ],
    visibility = ["//visibility:public"]
)

objc_library(
    name = "URLBuilder",
    hdrs = [
        "GTMURLBuilder.h"
    ],
    non_arc_srcs = [
        "GTMURLBuilder.m"
    ],
    deps = [
        "//:Core",
        "//:Defines",
        ":NSDictionary+URLArguments",
        ":NSString+URLArguments"
    ]
)

objc_library(
    name = "NSData+zlib",
    hdrs = [
        "GTMNSData+zlib.h",
    ],
    srcs = [
        "GTMNSData+zlib.m",
    ],
    deps = [
        "//:Defines"
    ],
    sdk_dylibs = ["libz"]
)

objc_library(
    name = "NSDictionary+URLArguments",
    hdrs = [
        "GTMNSDictionary+URLArguments.h",
    ],
    srcs = [
        "GTMNSDictionary+URLArguments.m",
    ],
    copts = ["-IDebugUtils"],
    deps = [
        "//:Defines",
        "//DebugUtils:DebugUtils",
        ":NSString+URLArguments"
    ]
)

objc_library(
    name = "NSFileHandle+UniqueName",
    hdrs = [
        "GTMNSFileHandle+UniqueName.h",
    ],
    non_arc_srcs = [
        "GTMNSFileHandle+UniqueName.m",
    ],
    deps = [
        "//:Defines"
    ],
)

objc_library(
    name = "NSScanner+JSON",
    hdrs = [
        "GTMNSScanner+JSON.h",
    ],
    srcs = [
        "GTMNSScanner+JSON.m",
    ],
    deps = [
        "//:Defines"
    ],
)

objc_library(
    name = "NSString+HTML",
    hdrs = [
        "GTMNSString+HTML.h",
    ],
    srcs = [
        "GTMNSString+HTML.m",
    ],
    deps = [
        "//:Core"
    ],
)

objc_library(
    name = "NSString+URLArguments",
    hdrs = [
        "GTMNSString+URLArguments.h",
    ],
    srcs = [
        "GTMNSString+URLArguments.m",
    ]
)

objc_library(
    name = "NSString+XML",
    hdrs = [
        "GTMNSString+XML.h",
    ],
    srcs = [
        "GTMNSString+XML.m",
    ],
    deps = [
        "//:Defines"
    ],
)

objc_library(
    name = "NSThread+Blocks",
    hdrs = [
        "GTMNSThread+Blocks.h",
    ],
    non_arc_srcs = [
        "GTMNSThread+Blocks.m",
    ],
    deps = [
        "//:Defines"
    ],
)

objc_library(
    name = "TimeUtils",
    hdrs = [
        "GTMTimeUtils.h",
    ],
    srcs = [
        "GTMTimeUtils.m",
    ],
    deps = [
        "//:Defines"
    ],
)
