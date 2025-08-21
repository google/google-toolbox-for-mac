load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "KVO",
    hdrs = [
        "Public/Foundation/GTMNSObject+KeyValueObserving.h",
    ],
    non_arc_srcs = [
        "GTMNSObject+KeyValueObserving.m",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    includes = [
        "Public/Foundation",
        "DebugUtils",
    ],
    copts = ["-IDebugUtils"],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
        "//DebugUtils",
    ],
)
