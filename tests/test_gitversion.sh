#!/bin/bash

BASEDIR=$(pwd)

function die
{
    echo "$1"
    exit 1
}

function shunittest_gitversion_use_correct_tag
{
    tdir=$(mktemp -d)
    trap "rm -fr ${tdir}" EXIT
    cd ${tdir}
    git init .
    touch README
    git add README
    git commit -m 'test' README
    git tag -a -m 1.0-0 build,1.0,0
    ${BASEDIR}/gitversion.sh > version.sh
    . version.sh
    [[ "$MAJOR" == "1.0" ]] || die "MAJOR should be 1.0, not $MAJOR"
    [[ "$BUILD" == "0" ]] || die "BUILD should be 0, not $BUILD"

    git checkout -b branch1
    echo 'This is a meaningless change' > README
    git commit -m 'edited readme' README
    git tag -a -m 2.0dev-0 build,2.0dev,0
    ${BASEDIR}/gitversion.sh > version.sh
    . version.sh
    [[ "$MAJOR" == "2.0dev" ]] || die "MAJOR should be 2.0dev, not $MAJOR"
    [[ "$BUILD" == "0" ]] || die "BUILD should be 0, not $BUILD"
    
    git checkout master
    ${BASEDIR}/gitversion.sh > version.sh
    . version.sh
    [[ "$MAJOR" == "1.0" ]] || die "MAJOR should be 1.0, not $MAJOR"
    [[ "$BUILD" == "0" ]] || die "BUILD should be 0, not $BUILD"
}

function shunittest_gitversion_correct_rebuilding
{
    tdir=$(mktemp -d)
    trap "rm -fr ${tdir}" EXIT
    cd ${tdir}
    git init .
    touch README
    git add README
    git commit -m 'test' README
    git tag -a -m 1.0-0 build,1.0,0
    ${BASEDIR}/gitversion.sh > version.sh
    . version.sh
    [[ "$REBUILDING" == "0" ]] || die "REBUILDING should be 0, not $REBUILDING"
    echo 'small meaningless change' > README
    git commit -m 'test 2' README
    ${BASEDIR}/gitversion.sh > version.sh
    . version.sh
    [[ "$REBUILDING" == "1" ]] || die "REBUILDING should be 1, not $REBUILDING"
    
}
