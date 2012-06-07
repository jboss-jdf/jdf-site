#!/usr/bin/env bash

GEMS=("hpricot" "awestruct" "nokogiri" "json" "git" "vpim" "rest-client" "pygments.rb")
EGGS=("pygments" "yuicompressor")
PACKAGES=("asciidoc")

if [ -z "$SUDO" ]; then
    SUDO="sudo"
fi

if [ -z "$EASY_INSTALL" ]; then
    EASY_INSTALL="easy_install"
fi



command_exists () {
    type "$1" &> /dev/null ;
}

echo "**** Setting up necessary Gems, Eggs and [RPMs|Mac Ports] for the jdf site"

echo "*** Gems"

g=${#EGGS[@]}
gi=0
installed_gems=`gem list --local`
while [ "$gi" -lt "$g" ]
do
  GEM=${#GEMS[gi]}
  if [[ $installed_gems != *${GEM}* ]]
  then
    echo "** Installing $GEM"
    $SUDO gem install $GEM $GEM_OPTIONS
  fi
  ((gi++))
done

e=${#EGGS[@]}
ei=0
echo "*** Eggs"
while [ "$ei" -lt "$e" ]
do
  EGG=${EGGS[ei]}
  echo "** Installing $EGG"
  $SUDO $EASY_INSTALL --upgrade $EASY_INSTALL_OPTIONS $EGG
  ((ei++))
done

echo "*** Packages"

pi=${#PACKAGES[@]}
p=0
while [ "$pi" -lt "$p" ]
do
  PACKAGE=${#PACKAGES[pi]}
  # Nice big hack :-D
  if ! command_exists $PACKAGE
  then
    if command_exists port
    then
      echo "** Installing $PACKAGE"
      $SUDO port install $PACKAGE
    fi

    if command_exists yum
    then
      echo "** Installing $PACKAGE"
      $SUDO yum install $PACKAGE
    fi
  fi
  ((pi++))
done

