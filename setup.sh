#!/usr/bin/env bash

# Canonicalise the source dir, allow this script to be called anywhere
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

GEMS=("hpricot" "awestruct" "nokogiri" "json" "git" "vpim" "rest-client" "pygments.rb")
EGGS=("pygments" "yuicompressor")
ASCIIDOC_VERSION="8.6.7"
ASCIIDOC_URL="http://downloads.sourceforge.net/project/asciidoc/asciidoc/8.6.7/asciidoc-8.6.7.tar.gz"


if [ -z "$SUDO" ]; then
    SUDO="sudo"
fi

if [ -z "$EASY_INSTALL" ]; then
    EASY_INSTALL="easy_install"
fi

if [ -z "$ASCIIDOC_HOME" ]; then
    ASCIIDOC_HOME="$DIR/_tmp/asciidoc_home"
fi

command_exists () {
    type "$1" &> /dev/null ;
}

function require_command {
    command -v $1 >/dev/null 2>&1 || { echo "I require $1 but it's not installed. Aborting." >&2; exit 1; }
}

echo "**** Setting up necessary Gems, Eggs and [RPMs|Mac Ports] for the jdf site"

echo "*** Testing environment"

require_command tar
require_command curl

echo "*** Gems"

g=${#GEMS[@]}
gi=0
installed_gems=`gem list --local`
while [ "$gi" -lt "$g" ]
do
  GEM=${GEMS[gi]}
  if [[ $installed_gems != *${GEM}* ]]
  then
    echo "** Installing $GEM"
    $SUDO gem install $GEM $GEM_OPTIONS
  fi
  ((gi++))
done

if ! command_exists "pip"
then
   echo "*** Setting up pip, the more modern Python egg installer"
   $SUDO $EASY_INSTALL $EASY_INSTALL_OPTIONS pip
fi

installed_eggs=`pip freeze`
e=${#EGGS[@]}
ei=0
echo "*** Eggs"
while [ "$ei" -lt "$e" ]
do
  EGG=${EGGS[ei]}
  if ! [[ $installed_egs != *${EGG}* ]]
  then
    echo "** Installing $EGG"
    $SUDO pip install $EGG
  fi
  ((ei++))
done

echo "*** AsciiDoc (oh, aren't you a one off)"

PACKAGE=asciidoc
if ! command_exists "asciidoc"
then
  export ASCIIDOC_BIN=${ASCIIDOC_HOME}/bin
  mkdir -p ${ASCIIDOC_HOME}
  mkdir -p ${ASCIIDOC_BIN}
  export ASCIIDOC_DIR=${ASCIIDOC_HOME}/asciidoc-${ASCIIDOC_VERSION}
  export PATH=${ASCIIDOC_BIN}:${PATH}
  echo "************ Please add ${ASCIIDOC_BIN} to your PATH. You probably want to move asciidoc to your system, and update your PATH globally."
  echo "************ Or, install asciidoc via your package manager :-)"
  cd ${ASCIIDOC_HOME}
  curl -L -O $ASCIIDOC_URL 

  tar -xzf asciidoc-${ASCIIDOC_VERSION}.tar.gz

  ln -sf ${ASCIIDOC_DIR}/asciidoc.py ${ASCIIDOC_BIN}/asciidoc
  ln -sf ${ASCIIDOC_DIR}/a2x.py ${ASCIIDOC_BIN}/a2x
fi

