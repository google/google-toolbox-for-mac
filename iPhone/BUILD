load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")

objc_library(
    name = "UILocalizer",
    hdrs = [
        "GTMUILocalizer.h",
    ],
    non_arc_srcs = [
        "GTMUILocalizer.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "UIImage_Resize",
    hdrs = [
        "GTMUIImage+Resize.h",
    ],
    non_arc_srcs = [
        "GTMUIImage+Resize.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "FadeTruncatingLabel",
    hdrs = [
        "GTMFadeTruncatingLabel.h",
    ],
    non_arc_srcs = [
        "GTMFadeTruncatingLabel.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "RoundedRectPath",
    srcs = [
        "GTMRoundedRectPath.m",
    ],
    hdrs = [
        "GTMRoundedRectPath.h",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "UIFont_LineHeight",
    srcs = [
        "GTMUIFont+LineHeight.m",
    ],
    hdrs = [
        "GTMUIFont+LineHeight.h",
    ],
    visibility = ["//visibility:public"],
)

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":UILocalizer",
        ":UIImage_Resize",
        ":FadeTruncatingLabel",
        ":RoundedRectPath",
        ":UIFont_LineHeight",
    ],
)
