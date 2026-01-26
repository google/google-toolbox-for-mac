load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSString_HTML",
    srcs = [
        "GTMNSString+HTML.m",
    ],
    hdrs = [
        "Public/Foundation/GTMNSString+HTML.h",
    ],
    includes = [
        "Public/Foundation",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
