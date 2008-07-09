#!/bin/sh
# BuildAllSDKs.sh
#
# This script builds both the Tiger and Leopard versions of the requested
# target in the current basic config (debug, release, debug-gcov).
#
# Copyright 2006-2008 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

PROJECT_TARGET="$1"
STARTING_TARGET="${TARGET_NAME}"
SCRIPT_APP="${TMPDIR}DoBuild.app"

REQUESTED_BUILD_STYLE=$(echo "${BUILD_STYLE}" | sed "s/.*OrLater-\(.*\)/\1/")
# See if we were told to clean instead of build.
PROJECT_ACTION="build"
if [ "${ACTION}" == "clean" ]; then
  PROJECT_ACTION="clean"
fi

# build up our AppleScript
OUR_BUILD_SCRIPT="on run
  tell application \"Xcode\"
    activate
    tell project \"GTM\"
      -- wait for build to finish
      set x to 0
      repeat while currently building
        delay 0.5
        set x to x + 1
        if x > 6 then
          display alert \"GTM is still building, can't start.\"
          return
        end if
      end repeat
      -- do the build
      with timeout of 9999 seconds
        set active target to target \"${PROJECT_TARGET}\"
        set buildResult to ${PROJECT_ACTION} using build configuration \"TigerOrLater-${REQUESTED_BUILD_STYLE}\"
        if buildResult is not equal to \"Build succeeded\" then
          set active target to target \"${STARTING_TARGET}\"
          return
        end if
        -- do not need the result since we are not doing another build
        ${PROJECT_ACTION} using build configuration \"LeopardOrLater-${REQUESTED_BUILD_STYLE}\"
        set active target to target \"${STARTING_TARGET}\"
      end timeout
    end tell
  end tell
end run"

# Xcode won't actually let us spawn this and run it w/ osascript because it
# watches and waits for everything we have spawned to exit before the build is
# considered done, so instead we compile this to a script app, and then use
# open to invoke it, there by escaping our little sandbox.
#   xcode defeats this: ( echo "${OUR_BUILD_SCRIPT}" | osascript - & )
rm -rf "${SCRIPT_APP}"
echo "${OUR_BUILD_SCRIPT}" | osacompile -o "${SCRIPT_APP}" -x 
open "${SCRIPT_APP}"
