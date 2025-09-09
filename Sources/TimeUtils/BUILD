load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "TimeUtils",
    srcs = [
        "GTMTimeUtils.m",
    ],
    hdrs = [
        "Public/Foundation/GTMTimeUtils.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
