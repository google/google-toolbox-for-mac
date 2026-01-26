load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSData_zlib",
    srcs = [
        "GTMNSData+zlib.m",
    ],
    hdrs = [
        "Public/Foundation/GTMNSData+zlib.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    sdk_dylibs = ["libz"],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
