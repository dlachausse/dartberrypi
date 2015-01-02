#!/bin/bash
# Copyright (c) 2015, Darren L. LaChausse
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

DART_SVN_BRANCH="1.8"

# The following functions are based upon the official Dart wiki on Google Code
# found at https://code.google.com/p/dart/wiki/RaspberryPi
function PreparingYourMachine {
	# This script installs the dependencies required to build the Dart SDK
	wget http://src.chromium.org/svn/trunk/src/build/install-build-deps.sh
        chmod u+x install-build-deps.sh
	./install-build-deps.sh --no-chromeos-fonts --no-nacl --arm --no-prompt
	# Install depot tools
	svn co http://src.chromium.org/svn/trunk/tools/depot_tools
	export PATH=$PATH:`pwd`/depot_tools

	# Install the default JDK
	sudo apt-get -y install default-jdk

	# Get Raspberry Pi cross compile build tools
	git clone https://github.com/raspberrypi/tools rpi-tools
}
function GettingTheSource {
	# Get the source code using depot tools
	gclient config http://dart.googlecode.com/svn/branches/$DART_SVN_BRANCH/deps/all.deps
	gclient sync
}
function DebianPackage {
	# Change to the dart directory, make an output directory, and build the
	# package
	(cd dart; \
	mkdir out; \
	./tools/create_tarball.py; \
	./tools/create_debian_packages.py -a armhf -t `pwd`/../rpi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf)
}

echo -e "\033[32m[Preparing your machine...]\033[0m"
PreparingYourMachine 
echo -e "\033[32m[Getting Dart SDK source code...]\033[0m"
GettingTheSource
echo -e "\033[32m[Building Debian package...]\033[0m"
DebianPackage

# Lets make sure that a Debian package was created before we say "Success!!!"
if [ -e dart/out/dart_*_armhf.deb ]
then
	echo -e "\033[32m[Success!!!]\033[0m"
	cp dart/out/dart_*_armhf.deb .
else
	echo -e "\033[31m[Fail]\033[0m"
	echo "Sorry, something went wrong"
fi

