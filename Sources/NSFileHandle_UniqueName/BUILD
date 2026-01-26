load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSFileHandle_UniqueName",
    hdrs = [
        "Public/Foundation/GTMNSFileHandle+UniqueName.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    non_arc_srcs = [
        "GTMNSFileHandle+UniqueName.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
