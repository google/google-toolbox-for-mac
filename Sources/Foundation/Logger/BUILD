load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_bundle")

objc_library(
    name = "Logger",
    srcs = [
        "GTMLogger.m",
    ],
    hdrs = [
        "Public/Foundation/GTMLogger.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
        ":LoggerPrivacyResources",
    ],
)

apple_resource_bundle(
    name = "LoggerPrivacyResources",
    resources = [
        "Resources/PrivacyInfo.xcprivacy",
    ],
    bundle_name = "Logger_PrivacyInfo",
    visibility = ["//visibility:public"],
)

objc_library(
    name = "LoggerASL",
    srcs = [
        "GTMLogger+ASL.m",
    ],
    hdrs = [
        "Public/Foundation/GTMLogger+ASL.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":Logger",
        "//:Defines",
    ],
)

objc_library(
    name = "LoggerRingBufferWriter",
    non_arc_srcs = [
        "GTMLoggerRingBufferWriter.m",
    ],
    hdrs = [
        "Public/Foundation/GTMLoggerRingBufferWriter.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":Logger",
        "//:Defines",
    ],
)
