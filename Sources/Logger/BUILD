load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_bundle")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

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
        ":LoggerPrivacyResources",
        "//:Defines",
    ],
)

apple_resource_bundle(
    name = "LoggerPrivacyResources",
    bundle_name = "Logger_PrivacyInfo",
    resources = [
        "Resources/PrivacyInfo.xcprivacy",
    ],
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
    hdrs = [
        "Public/Foundation/GTMLoggerRingBufferWriter.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    non_arc_srcs = [
        "GTMLoggerRingBufferWriter.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":Logger",
        "//:Defines",
    ],
)
