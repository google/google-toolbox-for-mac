load("@rules_cc//cc:objc_library.bzl", "objc_library")

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
