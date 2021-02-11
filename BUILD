load("@rules_cc//cc:defs.bzl", "objc_library")

objc_library(
    name = "Defines",
    hdrs = ["GTMDefines.h"],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "Core",
    srcs = [
        "//DebugUtils:GTMTypeCasting.h",
        "//Foundation:GTMLocalizedString.h",
        "//Foundation:GTMLogger.h"
    ],
    deps = [":Defines"],
    visibility = ["//visibility:public"]
)
