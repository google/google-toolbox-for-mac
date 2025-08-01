load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "LoggerLib",
    non_arc_srcs = [
        "GTMLoggerTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/Logger:Logger",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

objc_library(
    name = "LoggerASLLib",
    non_arc_srcs = [
        "GTMLogger+ASLTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/Logger:LoggerASL",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

objc_library(
    name = "LoggerRingBufferWriterLib",
    non_arc_srcs = [
        "GTMLoggerRingBufferWriterTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/Logger:LoggerRingBufferWriter",
        "//UnitTesting:SenTestCase",
        "//:Defines",
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
