"""Definitions for handling Bazel repositories for GoogleToolboxForMac. """

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.

    Args:
      repo_rule: The repository rule to be executed (e.g., `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)

def google_toolbox_for_mac_rules_dependencies():
    """Fetches repositories that are dependencies of GoogleToolboxForMac.

    Users should call this macro in their `WORKSPACE` to ensure that all of the
    dependencies are downloaded and that they are isolated
    from changes to those dependencies.
    """
    _maybe(
        http_archive,
        name = "rules_cc",
        # Latest 08-10-20
        urls = ["https://github.com/bazelbuild/rules_cc/archive/1477dbab59b401daa94acedbeaefe79bf9112167.tar.gz"],
        sha256 = "b87996d308549fc3933f57a786004ef65b44b83fd63f1b0303a4bbc3fd26bbaf",
        strip_prefix = "rules_cc-1477dbab59b401daa94acedbeaefe79bf9112167/",
    )

    _maybe(
        http_archive,
        name = "build_bazel_rules_apple",
        # Latest 2-11-21
        urls = ["https://github.com/bazelbuild/rules_apple/archive/c909dd759627f40e0fbd17112ba5e7b753755906.tar.gz"],
        strip_prefix = "rules_apple-c909dd759627f40e0fbd17112ba5e7b753755906/",
    )
