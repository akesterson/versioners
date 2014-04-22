#!/bin/bash

SEP=${VERSIONERS_SEPARATOR:-,}
VERSIONERS_TAGBASE=${VERSIONERS_TAGBASE:-build}

if [ "$MAKETAG" == "false" ]; then
    exit 0
fi

if [ ! -f version.sh ]; then
    $(dirname $BASH_SOURCE)/gitversion.sh > version.sh
fi

. ~/.buildtoolsrc || echo
. version.sh

WHOLETAG="${VERSIONERS_TAGBASE}${SEP}${MAJOR}${SEP}${BUILD}"

git fetch --tags

TAGSHA1=$(git rev-list $TAG | head -n 1)
if [ $REBUILDING -eq 0 ]; then
    echo "This is a rebuild of a previous tag, not tagging or pushing" >&2
elif [ "$(git tag | grep $WHOLETAG)" != "" ] && [ "$TAGSHA1" != "" ] && [ "$TAGSHA1" != "$SHA1" ]; then
    echo "Someone else tagged my buildnumber (${WHOLETAG}) onto $TAGSHA1, while I built it from $SHA1 ... "'Help!' >&2
    exit 1
elif [ "$TAGSHA1" != "" ] && [ "$TAGSHA1" == "$SHA1" ]; then
    echo "Someone else built this version at the same time I did, and we both tagged the same SHA1 with the same build tag. Not pushing my tag."
else
    git tag -f -a "${WHOLETAG}" -m "Tagging for ${MAJOR}-${BUILD}" $SHA1
    if [ "$PUSHTAG" != "false" ]; then
        git push --tags
    fi
fi
