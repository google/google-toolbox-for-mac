load("@rules_cc//cc:defs.bzl", "objc_library")

objc_library(
    name = "iPhone",
    hdrs = [
        "GTMFadeTruncatingLabel.h",
        "GTMUIImage+Resize.h",
        "GTMUILocalizer.h"
    ],
    non_arc_srcs = [
        "GTMFadeTruncatingLabel.m",
        "GTMUILocalizer.m"
    ],
    srcs = [
        "GTMUIImage+Resize.m"
    ],
    deps = [
        "//:Defines"
    ],
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
    ]
)

objc_library(
    name = "UIFont+LineHeight",
        hdrs = [
        "GTMUIFont+LineHeight.h",
    ],
    srcs = [
        "GTMUIFont+LineHeight.m"
    ],
)
