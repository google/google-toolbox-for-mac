load("@rules_cc//cc:defs.bzl", "objc_library")

objc_library(
    name = "TypeCasting",
    hdrs = [
        "GTMTypeCasting.h",
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "DebugUtils",
    hdrs = [
        "GTMDebugSelectorValidation.h",
        "GTMDebugThreadValidation.h",
        "GTMMethodCheck.h",
    ],
    copts = [
        "-IDebugUtils",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)
