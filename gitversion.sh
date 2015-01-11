#!/bin/bash

LOGSPEC='%ci %an <%aE>%n%n    %s%n    [%h]%d%n'
VERSIONERS_SEPARATOR=${VERSIONERS_SEPARATOR:-,}

BRANCH=$2
if [ "${BRANCH}" == "" ]; then
    BRANCH=$(git branch | grep '^\*\s*.*' | cut -d ' ' -f 2-)
fi

REBUILDING=0
SHA1=$(git rev-parse HEAD)
TAG=$(git describe --tags --abbrev=0 2>/dev/null)
BUILD=0
TAGSHA=$(git rev-list $TAG | head -n 1)
CHANGELOG="$(git log --format="format:$LOGSPEC" ${TAGSHA}..HEAD)"
if [ "$TAG" == "" ]; then
    BUILD=0
    REBUILDING=1
    MAJOR=$BRANCH
else
    MAJOR=$(echo $TAG | cut -d ${VERSIONERS_SEPARATOR} -f 2)
    BUILD=$(echo $TAG | cut -d ${VERSIONERS_SEPARATOR} -f 3)
    if [ "$TAGSHA" != "$SHA1" ]; then
        CHANGELOG="$(git log --format="format:$LOGSPEC" $TAGSHA..$SHA1)"
        BUILD=$(expr $BUILD + 1)
        REBUILDING=1
    else
        SHA1=$TAGSHA
    fi
fi

OS_NAME=""
OS_VERSION=""
if [ "$OS_NAME" == "" ] && [ "$(uname)" == "Darwin" ]; then
    OS_NAME="osx"
elif [ "$OS_NAME" == "" ] && [ -f /etc/redhat-release ]; then
    OS_NAME="el"
elif [ "$OS_NAME" == "" ] && [ "$(uname | grep -i '^MINGW')" != "" ] || [ "$(uname | grep -i '^CYGWIN')" != "" ]; then
    OS_NAME="win"
fi

if [ "$OS_VERSION" == "" ] && [ "$OS_NAME" == "el" ]; then
    OS_VERSION=$(cat /etc/redhat-release | grep -o "release [0-9]" | cut -d " " -f 2)
    RHEL_VERSION=$OS_VERSION
elif [ "$OS_VERSION" == "" ] && [ "$OS_NAME" == "osx" ]; then
    OS_VERSION="$(sw_vers | grep 'ProductVersion:' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
elif [ "$OS_VERSION" == "" ] && [ "$OS_NAME" == "win" ]; then
    echo "OS_VERSION unsupported on Microsoft Windows." >&2
fi

if [ "$ARCH" == "" ]; then
    if [ "$OS_NAME" == "osx" ]; then
        ARCH=$(uname -m)
    elif [ "$OS_NAME" != "win" ]; then
        ARCH=$(uname -i)
    elif [ "$OS_NAME" == "win" ]; then
        ARCH=$(uname -m)
    fi
fi

SOURCE=$((git remote show origin 2>/dev/null | grep "Fetch URL" | cut -d : -f 2- | cut -d ' ' -f 2-) || echo '')

echo "TAG=\"${TAG}\""
echo "BRANCH=\"${BRANCH}\""
echo "MAJOR=\"${MAJOR}\""
echo "BUILD=\"${BUILD}\""
echo "SHA1=\"${SHA1}\""
echo "OS_NAME=\"\${OS_NAME:-$OS_NAME}\""
echo "OS_VERSION=\"\${OS_VERSION:-$OS_VERSION}\""
echo "ARCH=\"\${ARCH:-$ARCH}\""
echo "VERSION=\"${MAJOR}-${BUILD}\""
echo "BUILDHOST=\"$(hostname)\""
echo "BUILDUSER=\"$(whoami)\""
echo "BUILDDIR=\"$(pwd)\""
echo "SOURCE=\"${SOURCE}\""
echo "REBUILDING=$REBUILDING"
echo "CHANGELOG=\"$CHANGELOG\""
