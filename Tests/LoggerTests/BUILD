load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "LoggerLib",
    testonly = 1,
    srcs = [
        "GTMLoggerTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/Logger",
        "//UnitTesting:SenTestCase",
    ],
)

objc_library(
    name = "LoggerASLLib",
    testonly = 1,
    srcs = [
        "GTMLogger+ASLTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/Logger:LoggerASL",
        "//UnitTesting:SenTestCase",
    ],
)

objc_library(
    name = "LoggerRingBufferWriterLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMLoggerRingBufferWriterTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/Logger:LoggerRingBufferWriter",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "LoggerUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":LoggerLib",
    ],
)

macos_unit_test(
    name = "LoggerMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":LoggerLib",
    ],
)

ios_unit_test(
    name = "LoggerASLUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":LoggerASLLib",
    ],
)

macos_unit_test(
    name = "LoggerASLMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":LoggerASLLib",
    ],
)

ios_unit_test(
    name = "LoggerRingBufferWriterUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":LoggerRingBufferWriterLib",
    ],
)

macos_unit_test(
    name = "LoggerRingBufferWriterMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":LoggerRingBufferWriterLib",
    ],
)
