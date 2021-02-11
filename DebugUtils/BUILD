load("@rules_cc//cc:defs.bzl", "objc_library")

exports_files([
    "GTMTypeCasting.h"
])

objc_library(
    name = "DebugUtils",
    hdrs = [
        "GTMDebugSelectorValidation.h",
        "GTMDebugThreadValidation.h",
        "GTMMethodCheck.h"
    ],
    deps = [
        "//:Defines"
    ],
    copts = [
        "-IDebugUtils"
    ],
    visibility = ["//visibility:public"]
)
