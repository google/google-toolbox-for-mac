load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":UILocalizer",
        ":UIImage_Resize",
        ":FadeTruncatingLabel",
        ":RoundedRectPath",
        ":UIFont_LineHeight"
    ],
)

objc_library(
    name = "UILocalizer",
    hdrs = [
        "GTMUILocalizer.h",
    ],
    non_arc_srcs = [
        "GTMUILocalizer.m",
    ],
    deps = [
        "//:Defines"
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "UIImage_Resize",
    hdrs = [
        "GTMUIImage+Resize.h",
    ],
    non_arc_srcs = [
        "GTMUIImage+Resize.m",
    ],
    deps = [
        "//:Defines"
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "FadeTruncatingLabel",
    hdrs = [
        "GTMFadeTruncatingLabel.h",
    ],
    non_arc_srcs = [
        "GTMFadeTruncatingLabel.m",
    ],
    deps = [
        "//:Defines"
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "RoundedRectPath",
    hdrs = [
        "GTMRoundedRectPath.h",
    ],
    srcs = [
        "GTMRoundedRectPath.m"
    ],
    deps = [
        "//:Defines"
    ],
    sdk_frameworks = [
        "CoreGraphics"
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "UIFont_LineHeight",
        hdrs = [
        "GTMUIFont+LineHeight.h",
    ],
    srcs = [
        "GTMUIFont+LineHeight.m"
    ],
    visibility = ["//visibility:public"],
)
