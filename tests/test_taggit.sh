#!/bin/bash

BASEDIR=$(pwd)

function die
{
    echo "$1"
    exit 1
}

function shunittest_test_environment_separator
{
    tdir=$(mktemp -d)
    trap "rm -fr ${tdir}" EXIT
    cd ${tdir}
    git init .
    touch README
    git add README
    git commit -m 'test' README
    VERSIONERS_SEPARATOR='X' ${BASEDIR}/taggit.sh 
    ${BASEDIR}/gitversion.sh > version.sh
    tag=$(git describe --tags --abbrev=0)
    [[ "$tag" == "buildXmasterX0" ]] || die "Tag should be buildXmasterX0, got $tag"
}

function shunittest_test_environment_tagbase
{
    tdir=$(mktemp -d)
    trap "rm -fr ${tdir}" EXIT
    cd ${tdir}
    git init .
    touch README
    git add README
    git commit -m 'test' README
    VERSIONERS_TAGBASE='release' ${BASEDIR}/taggit.sh 
    ${BASEDIR}/gitversion.sh > version.sh
    tag=$(git describe --tags --abbrev=0)
    [[ "$tag" == "release,master,0" ]] || die "Tag should be release,master,0, got $tag"
}
