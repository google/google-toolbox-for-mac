load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "StackTrace",
    hdrs = [
        "Public/Foundation/GTMStackTrace.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    non_arc_srcs = [
        "GTMStackTrace.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
