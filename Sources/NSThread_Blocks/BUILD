load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSThread_Blocks",
    hdrs = [
        "Public/Foundation/GTMNSThread+Blocks.h",
    ],
    non_arc_srcs = [
        "GTMNSThread+Blocks.m",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
