load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

alias(
    name = "LocalizedString",
    actual = "//Sources/Foundation/LocalizedString:LocalizedString",
    visibility = ["//visibility:public"],
)

alias(
    name = "GeometryUtils",
    actual = "//Sources/Foundation/GeometryUtils:GeometryUtils",
    visibility = ["//visibility:public"],
)

alias(
    name = "KVO",
    actual = "//Sources/Foundation/KVO:KVO",
    visibility = ["//visibility:public"],
)

alias(
    name = "Logger",
    actual = "//Sources/Foundation/Logger:Logger",
    visibility = ["//visibility:public"],
)

alias(
    name = "StackTrace",
    actual = "//Sources/Foundation/StackTrace:StackTrace",
    visibility = ["//visibility:public"],
)

alias(
    name = "StringEncoding",
    actual = "//Sources/Foundation/StringEncoding:StringEncoding",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSData_zlib",
    actual = "//Sources/Foundation/NSData_zlib:NSData_zlib",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSFileHandle_UniqueName",
    actual = "//Sources/Foundation/NSFileHandle_UniqueName:NSFileHandle_UniqueName",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSString_HTML",
    actual = "//Sources/Foundation/NSString_HTML:NSString_HTML",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSString_XML",
    actual = "//Sources/Foundation/NSString_XML:NSString_XML",
    visibility = ["//visibility:public"],
)

alias(
    name = "NSThread_Blocks",
    actual = "//Sources/Foundation/NSThread_Blocks:NSThread_Blocks",
    visibility = ["//visibility:public"],
)

alias(
    name = "TimeUtils",
    actual = "//Sources/Foundation/TimeUtils:TimeUtils",
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
