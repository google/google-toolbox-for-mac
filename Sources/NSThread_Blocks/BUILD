load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSThread_Blocks",
    hdrs = [
        "Public/Foundation/GTMNSThread+Blocks.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    non_arc_srcs = [
        "GTMNSThread+Blocks.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
