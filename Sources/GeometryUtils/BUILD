load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "GeometryUtils",
    srcs = [
        "GTMGeometryUtils.m",
    ],
    hdrs = [
        "Public/Foundation/GTMGeometryUtils.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    sdk_frameworks = [
        "CoreGraphics",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
