load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

objc_library(
    name = "GeometryUtils",
    srcs = [
        "GTMGeometryUtils.m",
    ],
    hdrs = [
        "Public/Foundation/GTMGeometryUtils.h",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
