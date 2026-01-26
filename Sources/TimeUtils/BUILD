load("@rules_cc//cc:objc_library.bzl", "objc_library")

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
