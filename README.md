Versioners
==========

This is a set of scripts that I use for automatically tagging, and generating version/build metadata for, mercurial and git projects. They provide your automation with quite a bit of information about the version being built, where it is built, and who built it. They also generate automatic changelogs for you.

Assumptions
===========

*PRIMARILY, THIS ASSUMES YOU ARE USING A BASH SCRIPT-CAPABLE BUILD ENVIRONMENT. THESE ARE BASH SCRIPTS.*

This assumes you want your project versioned like this:

    (MAJOR)-(BUILD)

... Where MAJOR will default to the name of the current branch, or the value of MAJOR on the previous tag (of the current branch). BUILD will default to 0, or the BUILD of the last tag (on the current branch) plus one.

All builds will be tagged thusly:

    build,(MAJOR),(BUILD)

If you want your project to use a MAJOR that is NOT equal to the branch name (e.g. you want branch 'master' to be '1.1'), then you must set an initial tag on that branch, e.g:

    build,1.1,0

... And then the scripts will use 1.1, instead of 'master', as the MAJOR version component.

Operating System Info
=====================

There are two variables, OS_NAME and OS_VERSION, automatically provided by the script.

OS_NAME possible values:
* win
* osx
* el (RedHat/CentOS/Fedora linux)

OS_VERSION will contain the version number of the OS_NAME in question, except for 'win', which does not have compact or sane version numbers.

These don't support debian yet - feel free to submit a patch.

Installing
==========

```
make install
```

The default location is in `/usr`. To change the installation location specify `PREFIX`

```
PREFIX=/custom/location make install
```

Generate a version
==================

Two scripts, 'gitversion.sh' and 'hgversion.sh' generate version metadata for git and hg, respectively. The data output by these two is meant to be consumed by bash.

    []$ gitversion.sh
    TAG="build,6.3.0,0"
    BRANCH="6.3.0"
    MAJOR="6.3.0"
    BUILD="0"
    SHA1="9392ee5cc8da"
    OS_NAME="${OS_NAME:-win}"
    OS_VERSION="${OS_VERSION:-}"
    ARCH="${ARCH:-i686}"
    VERSION="6.3.0-0"
    BUILDHOST="akesterson-pc"
    BUILDUSER="akesterson"
    BUILDDIR="/c/Users/akesterson/source/upstream/hg/project"
    SOURCE="http://bitbucket.org/akesterson/project"
    REBUILDING=1
    CHANGELOG=""

This can be piped into a bash script for later sourcing. You can source this into a variety of other languages as well (python or ruby), but the ${:-} syntax is bash specific, and might confuse other languages.

The changelog will contain a brief log of all commits between the previous build tag and this build.

Cutting a Tag
=============

To cut a tag, just run 'taggit.sh' or 'taghg.sh':

    []$ taggit.sh

... This will tag the current revision with a new build number. UNLESS:

* The current revision has already been tagged (e.g., this is just a rebuild)
* The buildnumber that we were going to use has been tagged somewhere else on this branch
* This is not marked as a rebuild, but someone else just tagged the version  with the same build number we would have (e.g., distributed build systems)
