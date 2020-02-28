#!/bin/bash

echo "Setting up dev environment..."

# Open Console build environment setup
# Adds msbuild to your path, and adds the open/tools directory as well
# This recreates what it's like to be an actual windows developer!

# skip the setup if we're already ready.
if [ -n "$OpenConBuild" ]; then
	echo "The dev environment is ready to go!"
	return
fi

# Get absolute path of this script's directory. Simulates "%~dp0" on Windows.
HERE="$(realpath $(dirname $0))"

# Add Opencon build scripts to path
export PATH="$PATH:$HERE"

# add some helper envvars - The Opencon root, and also the processor arch, for output paths
export OPENCON_TOOLS="$HERE"
# The opencon root is at .../open/tools/..
export OPENCON="$(realpath $HERE/..)"

# Add nuget to PATH
export PATH="$PATH:$OPENCON/dep/nuget.exe" # TODO

# Run nuget restore so you can use vswhere
nuget.exe restore "$OPENCON" -Verbosity quiet
# TODO: This reads from $OPENCON/.nuget/packages.config to load vswhere

# Find vswhere
# TODO

if [ -z "$VSWHERE" ]; then
	echo "Could not find vswhere on your machine. Please set the VSWHERE variable to the location of vswhere.exe and run razzle again."
	return
fi

# Add path to MSBuild Binaries
# TODO

# Try to find MSBuild in prerelease versions of MSVS
if [ -z "$MSBUILD" ]; then
	# TODO
fi

if [ -z "$MSBUILD" ]; then
	echo "Could not find MsBuild on your machine. Please set the MSBUILD variable to the location of MSBuild.exe and run razzle again."
	return
fi

export PATH="$PATH:$MSBUILD/.."

if [ "$(uname -m)" = "x86_64" ]; then
	export ARCH="x64"
	export PLATFORM="Posix64" # TODO
else
	export ARCH="x86"
	export PLATFORM="Posix32" # TODO
fi

# call .razzlerc - for your generic razzle environment stuff
RAZZLERC="$OPENCON_TOOLS/.razzlerc.sh"
if [ -f RAZZLERC ]; then
	$SHELL RAZZLERC
else
	echo "# This is your razzlerc file. It can be used for default dev environment setup." > "$RAZZLERC"
fi

# if there are args, run them. This can be used for additional env. customization,
# especially on a per shortcut basis.
for arg in "$@"; do
	if [ "$arg" = "dbg" ]; then
		export DEFAULT_CONFIGURATION="Debug"
	elif [ "$arg" = "rel" ]; then
		export DEFAULT_CONFIGURATION="Release"
	elif [ "$arg" = "x86" ]; then
		export ARCH="x86"
		export PLATFORM="Posix32" # TODO
	elif [ -f "$arg" ]; then
		$SHELL "$arg"
	else
		echo "Could not locate \"$arg\""
	fi
done
# TODO: Set TAEF envvar
# Set this envvar so setup won't repeat itself
export OpenConBuild=true

echo "The dev environment is ready to go!"
