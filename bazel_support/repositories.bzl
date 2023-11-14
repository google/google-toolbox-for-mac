"""Definitions for handling Bazel repositories for GoogleToolboxForMac. """

def google_toolbox_for_mac_rules_dependencies():
    """Fetches repositories that are dependencies of GoogleToolboxForMac.

    Users should call this macro in their `WORKSPACE` to ensure that all of the
    dependencies are downloaded and that they are isolated
    from changes to those dependencies.
    """
    # Nothing for now, since rules_apple has so many waves of transitive deps.
    # Preserved to maintain API stability and for future flexibility.
    pass
