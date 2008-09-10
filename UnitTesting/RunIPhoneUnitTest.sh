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
  
  # Encourage errors
  export MallocScribble=YES
  export MallocPreScribble=YES
  export MallocGuardEdges=YES
  export CFZombieLevel=3
  export NSAutoreleaseFreedObjectCheckEnabled=YES
  export NSZombieEnabled=YES
  export OBJC_DEBUG_FRAGILE_SUPERCLASSES=YES

  "$TARGET_BUILD_DIR/$EXECUTABLE_PATH" -RegisterForSystemEvents
else
  echo "note: Skipping running of unittests for device build."
fi
exit 0
