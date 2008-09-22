#!/bin/sh
#  RunIPhoneUnitTest.sh
#  Copyright 2008 Google Inc.
#  
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not
#  use this file except in compliance with the License.  You may obtain a copy
#  of the License at
# 
#  http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
#  License for the specific language governing permissions and limitations under
#  the License.
#
#  Runs all unittests through the iPhone simulator. We don't handle running them
#  on the device. To run on the device just choose "run".

# Controlling environment variables:
#
# GTM_DISABLE_ZOMBIES - 
#   Set to a non-zero value to turn off zombie checks that can interfere with 
#   leak checking.
#
# GTM_DISABLE_LEAKS -
#   Set to a non-zero value to turn off the leaks check.
#
# GTM_DISABLE_TERMINATION
#   Set to a non-zero value so that the app doesn't terminate when it's finished
#   running tests. This is useful when using it with external tools such
#   as Instruments.

ScriptDir=$(dirname $(echo $0 | sed -e "s,^\([^/]\),$(pwd)/\1,"))
ScriptName=$(basename "$0")
ThisScript="${ScriptDir}/${ScriptName}"

GTMXcodeNote() {
    echo ${ThisScript}:${1}: note: GTM ${2}
}

if [ "$IPHONEOS_DEPLOYMENT_TARGET" == "" ]; then
  # We kill the iPhone simulator because otherwise we run into issues where
  # the unittests fail becuase the simulator is currently running, and 
  # at this time the iPhone SDK won't allow two simulators running at the same
  # time.
  /usr/bin/killall "iPhone Simulator"

  export DYLD_ROOT_PATH="$SDKROOT"
  export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
  export IPHONE_SIMULATOR_ROOT="$SDKROOT"
  export CFFIXED_USER_HOME="$USER_LIBRARY_DIR/Application Support/iPhone Simulator/User"
  
  # See http://developer.apple.com/technotes/tn2004/tn2124.html for an 
  # explanation of these environment variables.
  
  export MallocScribble=YES
  export MallocPreScribble=YES
  export MallocGuardEdges=YES
  export MallocStackLogging=YES
  export NSAutoreleaseFreedObjectCheckEnabled=YES
  export OBJC_DEBUG_FRAGILE_SUPERCLASSES=YES

  if [ ! $GTM_DISABLE_ZOMBIES ]; then
    GTMXcodeNote ${LINENO} "Enabling zombies"
    export CFZombieLevel=3
    export NSZombieEnabled=YES
  fi

  "$TARGET_BUILD_DIR/$EXECUTABLE_PATH" -RegisterForSystemEvents
else
  GTMXcodeNote ${LINENO} "Skipping running of unittests for device build."
fi
exit 0
