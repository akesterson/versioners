#!/bin/bash

if [ "$MAKETAG" == "false" ]; then
    exit 0
fi

if [ ! -f version ]; then
    ${dirname $BASH_SOURCE)/genversion > version
fi

. ~/.buildtoolsrc
. version
hg pull -u --branch $(hg branch)

TAGSHA1=$(cat .hgtags | grep "build,${MAJOR},${BUILD}" | cut -d " " -f 1)
echo "$TAGSHA1" | grep "^$SHA1" >/dev/null 2>&1
SHORTSHAMATCH=$?
if [ $REBUILDING -eq 0 ]; then
    echo "This is a rebuild of a previous tag, not tagging or pushing" >&2
elif [ "$TAGSHA1" != "" ] && [ $SHORTSHAMATCH -ne 0 ]; then
    echo "Someone else tagged my buildnumber (branch|${MAJOR}|${BUILD}) onto $TAGSHA1, while I built it from $SHA1 ... "'Help!' >&2
    exit 1
elif [ "$TAGSHA1" != "" ] && [ $SHORTSHAMATCH -eq 0 ]; then
    echo "Someone else built this version at the same time I did, and we both tagged the same SHA1 with the same build tag. Not pushing my tag."
else
    hg tag -f -r ${SHA1} "build|${MAJOR}|${BUILD}"
    if [ "$PUSHTAG" != "false" ]; then
	hg push
    fi
fi
