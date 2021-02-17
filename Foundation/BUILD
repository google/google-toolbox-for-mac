load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":LocalizedString",
        ":GeometryUtils", 
        ":KVO",
        ":Logger",
        ":Regex",
        ":StackTrace",
        ":StringEncoding",
        ":SystemVersion",
        ":URLBuilder",
        ":NSData_zlib",
        ":NSDictionary_URLArguments",
        ":NSFileHandle_UniqueName",
        ":NSScanner_JSON",
        ":NSString_HTML",
        ":NSString_URLArguments",
        ":NSString_XML",
        ":NSThread_Blocks",
        ":TimeUtils"
    ],
)

objc_library(
    name = "LocalizedString",
    hdrs = [
        "GTMLocalizedString.h",
    ],
    visibility = ["//visibility:public"]
)

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
        "//:Defines",
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
        "//:Defines",
        ":NSDictionary_URLArguments",
        ":NSString_URLArguments",
        ":Logger"
    ]
)

objc_library(
    name = "NSData_zlib",
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
    name = "NSDictionary_URLArguments",
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
        ":NSString_URLArguments"
    ]
)

objc_library(
    name = "NSFileHandle_UniqueName",
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
    name = "NSScanner_JSON",
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
    name = "NSString_HTML",
    hdrs = [
        "GTMNSString+HTML.h",
    ],
    srcs = [
        "GTMNSString+HTML.m",
    ],
    deps = [
        "//:Defines"
    ],
)

objc_library(
    name = "NSString_URLArguments",
    hdrs = [
        "GTMNSString+URLArguments.h",
    ],
    srcs = [
        "GTMNSString+URLArguments.m",
    ]
)

objc_library(
    name = "NSString_XML",
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
    name = "NSThread_Blocks",
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
