load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSData_zlib",
    srcs = [
        "GTMNSData+zlib.m",
    ],
    hdrs = [
        "Public/Foundation/GTMNSData+zlib.h",
    ],
    sdk_dylibs = ["libz"],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
