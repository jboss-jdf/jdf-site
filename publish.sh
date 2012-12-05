#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Define
SANDBOX_URL="site-jdf.rhcloud.com"
SANDBOX_SSH_USERNAME="f35451447e0d4bfbaf37c8a039bb5e6a"
SANDBOX_REPO="ssh://${SANDBOX_SSH_USERNAME}@${SANDBOX_URL}/~/git/site.git/"
SANDBOX_CHECKOUT_DIR=$DIR/_tmp/sandbox

# team email subject
EMAIL_SUBJECT="JDF site released at \${PRODUCTION_URL}"
# EAP team email To ?
EMAIL_TO="jdf-dev@lists.jboss.org"
EMAIL_FROM="\"JDF Publish Script\" <benevides@redhat.com>"

JBORG_DIR="jdf"
JBORG_REPO="filemgmt.jboss.org:www_htdocs"

STAGING_URL="jboss.org/${JBORG_DIR}/stage"
STAGING_DIR="${JBORG_DIR}/stage"

PRODUCTION_DIR="${JBORG_DIR}"
PRODUCTION_URL="jboss.org/${PRODUCTION_DIR}"

notifyEmail()
{
   echo "***** Performing JDF site release notifications"
   echo "*** Notifying JDF dev list"
   subject=`eval echo $EMAIL_SUBJECT`
   echo "Email from: " $EMAIL_FROM
   echo "Email to: " $EMAIL_TO
   echo "Subject: " $subject
   # send email using /bin/mail
   echo "See \$subject :-)" | /usr/bin/env mail -r "$EMAIL_FROM" -s "$subject" "$EMAIL_TO"

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
  rsync -Pqr --protocol=28 --delete-after $DIR/_site/* ${JBORG_DIR}@${JBORG_REPO}/${PRODUCTION_DIR}

  shallow_clean
  
  read -p "Do you want to send release notifcations to $EMAIL_TO[y/N]? " yn
  case $yn in
      [Yy]* ) notifyEmail;;
      * ) exit;
  esac
}

staging() {
  deep_clean
  echo "**** Generating site ****"
  awestruct -Pstaging

  echo "**** Publishing site to http://${STAGING_URL} ****"
  rsync -Pqr --protocol=28 --delete-after $DIR/_site/* ${JBORG_DIR}@${JBORG_REPO}/${STAGING_DIR}

  shallow_clean
}

clear_staging() {
  echo "**** Removing staging site from http://${STAGING_URL}"
  rm -rf _site
  mkdir _site
  rsync -Pqr --protocol=28 --delete $DIR/_site/ ${JBORG_DIR}@${JBORG_REPO}/${STAGING_DIR}
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
   -r      Remove the staging version of the site from http://${STAGING_URL} - please do this after using staging
EOF
}

while getopts "spdchr" OPTION

do
     case $OPTION in
         s)
             staging
             exit
             ;;
         r)
             clear_staging
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
