load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

objc_library(
    name = "LocalizedString",
    hdrs = [
        "GTMLocalizedString.h",
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "GeometryUtils",
    srcs = [
        "GTMGeometryUtils.m",
    ],
    hdrs = [
        "GTMGeometryUtils.h",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "KVO",
    hdrs = [
        "GTMNSObject+KeyValueObserving.h",
    ],
    copts = ["-IDebugUtils"],
    non_arc_srcs = [
        "GTMNSObject+KeyValueObserving.m",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
        "//DebugUtils",
    ],
)

objc_library(
    name = "Logger",
    hdrs = [
        "GTMLogger.h",
    ],
    non_arc_srcs = [
        "GTMLogger.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "StackTrace",
    hdrs = [
        "GTMStackTrace.h",
    ],
    non_arc_srcs = [
        "GTMStackTrace.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "StringEncoding",
    hdrs = [
        "GTMStringEncoding.h",
    ],
    non_arc_srcs = [
        "GTMStringEncoding.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "NSData_zlib",
    srcs = [
        "GTMNSData+zlib.m",
    ],
    hdrs = [
        "GTMNSData+zlib.h",
    ],
    sdk_dylibs = ["libz"],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "NSFileHandle_UniqueName",
    hdrs = [
        "GTMNSFileHandle+UniqueName.h",
    ],
    non_arc_srcs = [
        "GTMNSFileHandle+UniqueName.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "NSString_HTML",
    srcs = [
        "GTMNSString+HTML.m",
    ],
    hdrs = [
        "GTMNSString+HTML.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "NSString_XML",
    srcs = [
        "GTMNSString+XML.m",
    ],
    hdrs = [
        "GTMNSString+XML.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
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
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "TimeUtils",
    srcs = [
        "GTMTimeUtils.m",
    ],
    hdrs = [
        "GTMTimeUtils.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":LocalizedString",
        ":GeometryUtils",
        ":KVO",
        ":Logger",
        ":StackTrace",
        ":StringEncoding",
        ":NSData_zlib",
        ":NSFileHandle_UniqueName",
        ":NSString_HTML",
        ":NSString_XML",
        ":NSThread_Blocks",
        ":TimeUtils",
    ],
)

macos_build_test(
    name = "macOSBuildTest",
    minimum_os_version = "10.10",
    targets = [
        ":LocalizedString",
        ":GeometryUtils",
        ":KVO",
        ":Logger",
        ":StackTrace",
        ":StringEncoding",
        ":NSData_zlib",
        ":NSFileHandle_UniqueName",
        ":NSString_HTML",
        ":NSString_XML",
        ":NSThread_Blocks",
        ":TimeUtils",
    ],
)
