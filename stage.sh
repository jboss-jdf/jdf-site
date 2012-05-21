#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

OPENSHIFT_REPO="ssh://f35451447e0d4bfbaf37c8a039bb5e6a@site-jdf.rhcloud.com/~/git/site.git/"
OPENSHIFT_DIR=$DIR/_tmp/stage

# Script to stage site to site-jdf.rhcloud.com

echo "**** Cleaning _site  ****"
rm -rf $DIR/_site

echo "**** Generating site ****"
awestruct -Pstaging

if [ ! -d "$OPENSHIFT_DIR/.git" ]; then
    echo "**** Cloning OpenShift repo ****"
    mkdir -p $OPENSHIFT_DIR
    git clone $OPENSHIFT_REPO $OPENSHIFT_DIR
fi

cp -rf $DIR/_site/* $OPENSHIFT_DIR/php

cd $OPENSHIFT_DIR
git add *
git commit -a -m"deploy"
git push -f

