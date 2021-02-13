workspace(name = "google_toolbox_for_mac")

load(
    "@google_toolbox_for_mac//bazel_support:repositories.bzl",
    "google_toolbox_for_mac_rules_dependencies",
)

google_toolbox_for_mac_rules_dependencies()

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()