load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "StringEncoding",
    srcs = [
        "GTMStringEncoding.m",
    ],
    hdrs = [
        "Public/Foundation/GTMStringEncoding.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
