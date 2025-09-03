load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

alias(
    name = "LocalizedString",
    actual = "//Sources/LocalizedString:LocalizedString",
    visibility = ["//visibility:public"],
)

alias(
    name = "GeometryUtils",
    actual = "//Sources/GeometryUtils:GeometryUtils",
    visibility = ["//visibility:public"],
)

alias(
    name = "KVO",
    actual = "//Sources/KVO:KVO",
    visibility = ["//visibility:public"],
)

alias(
    name = "Logger",
    actual = "//Sources/Logger:Logger",
    visibility = ["//visibility:public"],
)

alias(
    name = "StackTrace",
    actual = "//Sources/StackTrace:StackTrace",
    visibility = ["//visibility:public"],
)

alias(
    name = "StringEncoding",
    actual = "//Sources/StringEncoding:StringEncoding",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSData_zlib",
    actual = "//Sources/NSData_zlib:NSData_zlib",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSFileHandle_UniqueName",
    actual = "//Sources/NSFileHandle_UniqueName:NSFileHandle_UniqueName",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSString_HTML",
    actual = "//Sources/NSString_HTML:NSString_HTML",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSString_XML",
    actual = "//Sources/NSString_XML:NSString_XML",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSThread_Blocks",
    actual = "//Sources/NSThread_Blocks:NSThread_Blocks",
    visibility = ["//visibility:public"],
)

alias(
    name = "TimeUtils",
    actual = "//Sources/TimeUtils:TimeUtils",
    visibility = ["//visibility:public"],
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
