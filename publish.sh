#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Define
SANDBOX_URL="site-jdf.rhcloud.com"
SANDBOX_SSH_USERNAME="f35451447e0d4bfbaf37c8a039bb5e6a"
SANDBOX_REPO="ssh://${SANDBOX_SSH_USERNAME}@${SANDBOX_URL}/~/git/site.git/"
SANDBOX_CHECKOUT_DIR=$DIR/_tmp/sandbox

# EAP team email subject
EAP_SUBJECT="JDF site released at \${PRODUCTION_URL}"
# EAP team email To ?
EAP_EMAIL_TO="jdf-dev@lists.jboss.org"
EAP_EMAIL_FROM="\"JDF Publish Script\" <benevides@redhat.com>"

JBORG_DIR="jdf"
JBORG_REPO="filemgmt.jboss.org:www_htdocs"

# TODO Back After 2.0.0 Release STAGING_URL="jboss.org/${JBORG_DIR}/stage"
# TODO Back After 2.0.0 Release STAGING_DIR="${JBORG_DIR}/stage"
STAGING_URL="jboss.org/${JBORG_DIR}/2.0.0"
STAGING_DIR="${JBORG_DIR}/2.0.0"

PRODUCTION_DIR="${JBORG_DIR}"
PRODUCTION_URL="jboss.org/${PRODUCTION_DIR}"

notifyEmail()
{
   echo "***** Performing JDF site release notifications"
   echo "*** Notifying JDF dev list"
   subject=`eval echo $EAP_SUBJECT`
   echo "Email from: " $EAP_EMAIL_FROM
   echo "Email to: " $EAP_EMAIL_TO
   echo "Subject: " $subject
   # send email using /bin/mail
   echo "See \$subject :-)" | /usr/bin/env mail -r "$EAP_EMAIL_FROM" -s "$subject" "$EAP_EMAIL_TO"

}


shallow_clean() {
  echo "**** Cleaning site  ****"
  rm -rf $DIR/_site
  echo "**** Cleaning asciidoc cache  ****"
  rm -rf $DIR/_tmp/asciidoc
}

deep_clean() {
  echo "**** Cleaning site  ****"
  rm -rf $DIR/_site
  echo "**** Cleaning caches  ****"
  rm -rf $DIR/_tmp/lanyrd
  rm -rf $DIR/_tmp/remote_partial
  rm -rf $DIR/_tmp/datacache
  rm -rf $DIR/_tmp/restcache
  rm -rf $DIR/_tmp/asciidoc
}

sandbox() {
  shallow_clean
  echo "**** Generating site ****"
  awestruct -Psandbox

  if [ ! -d "$SANDBOX_CHECKOUT_DIR/.git" ]; then
    echo "**** Cloning OpenShift repo ****"
    mkdir -p $SANDBOX_CHECKOUT_DIR
    git clone $SANDBOX_REPO $SANDBOX_CHECKOUT_DIR
  fi

  cp -rf $DIR/_site/* $SANDBOX_CHECKOUT_DIR/php


  echo "**** Publishing site to http://${SANDBOX_URL} ****"
  cd $SANDBOX_CHECKOUT_DIR
  git add *
  git commit -a -m"deploy"
  git push -f
  shallow_clean
}

production() {
  deep_clean
  echo "**** Generating site ****"
  awestruct -Pproduction

  echo "**** Publishing site to http://${PRODUCTION_URL} ****"
  rsync -Pqr --protocol=28 $DIR/_site/* ${JBORG_DIR}@${JBORG_REPO}/${PRODUCTION_DIR}

  shallow_clean

  notifyEmail
}

staging() {
  deep_clean
  echo "**** Generating site ****"
  awestruct -Pstaging

  echo "**** Publishing site to http://${STAGING_URL} ****"
  rsync -Pqr --protocol=28 $DIR/_site/* ${JBORG_DIR}@${JBORG_REPO}/${STAGING_DIR}

  shallow_clean
}


usage() {
  cat << EOF
usage: $0 options

This script publishes the JDF site, either to sandbox, staging or to production

OPTIONS:
   -d      Publish *sandbox* version of the site to http://${SANDBOX_URL}
   -s      Publish staging version of the site to http://${STAGING_URL}
   -p      Publish production version of the site to http://${PRODUCTION_URL}
   -c      Clear out all caches
EOF
}

while getopts "spdch" OPTION

do
     case $OPTION in
         s)
             staging
             exit
             ;;
         d)
             sandbox
             exit
             ;;
         p)
             production
             exit
             ;;
         c)
             deep_clean
             exit
             ;;
         h)
             usage
             exit
             ;;
         [?])
             usage
             exit
             ;;
     esac
done

usage
