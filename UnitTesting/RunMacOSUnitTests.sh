#
#  RunMacOSUnitTests.sh
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
#  Run the unit tests in this test bundle.
#  Set up some env variables to make things as likely to crash as possible.
#  See http://developer.apple.com/technotes/tn2004/tn2124.html for details.
#

# Controlling environment variables:
#
# GTM_NO_MEMORY_STRESS - 
#   Set to zero to prevent the setting of system library/framework debugging
#   environment variables that help find problems in code. See
#   http://developer.apple.com/technotes/tn2004/tn2124.html
#   for details.
# GTM_NO_DEBUG_FRAMEWORKS -
#   Set to zero to prevent the use of the debug versions of system
#   libraries/frameworks if you have them installed on your system. The frameworks
#   can be found at http://connect.apple.com > Downloads > Developer Tools
#   (https://connect.apple.com/cgi-bin/WebObjects/MemberSite.woa/wa/getSoftware?bundleID=19915)

ScriptDir=$(dirname $(echo $0 | sed -e "s,^\([^/]\),$(pwd)/\1,"))
ScriptName=$(basename "$0")
ThisScript="${ScriptDir}/${ScriptName}"

GTMXcodeNote() {
    echo ${ThisScript}:${1}: note: GTM ${2}
}

# Jack up some memory stress so we can catch more bugs.
if [ ! $GTM_NO_MEMORY_STRESS ]; then
  GTMXcodeNote ${LINENO} "Enabling memory stressing"
  export MallocScribble=YES
  export MallocPreScribble=YES
  export MallocGuardEdges=YES
  # CFZombieLevel disabled because it doesn't play well with the 
  # security framework
  # export CFZombieLevel=3
  export NSAutoreleaseFreedObjectCheckEnabled=YES
  export NSZombieEnabled=YES
  export OBJC_DEBUG_FRAGILE_SUPERCLASSES=YES
fi

# If we have debug libraries on the machine, we'll use them
# unless a target has specifically turned them off
if [ ! $GTM_NO_DEBUG_FRAMEWORKS ]; then
  if [ -f "/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation_debug" ]; then
    GTMXcodeNote ${LINENO} "Using _debug frameworks"
    export DYLD_IMAGE_SUFFIX=_debug
  fi
fi

"${SYSTEM_DEVELOPER_DIR}/Tools/RunUnitTests"
