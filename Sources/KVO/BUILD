load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "KVO",
    srcs = [
        "GTMNSObject+KeyValueObserving.m",
    ],
    hdrs = [
        "Public/Foundation/GTMNSObject+KeyValueObserving.h",
    ],
    copts = ["-IDebugUtils"],
    includes = [
        "DebugUtils",
        "Public/Foundation",
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
