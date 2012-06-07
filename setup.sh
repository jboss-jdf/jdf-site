#!/usr/bin/env bash

GEMS=("hpricot" "awestruct" "nokogiri" "json" "git" "vpim" "rest-client" "pygments.rb")
EGGS=("pygments" "yuicompressor")
PORTS="asciidoc"
RPMS=$PORTS

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
while [ "$gi" -lt "$g" ]
do
  GEM=${GEMS[gi]}
  if gem list | grep -q "${GEM}"
  then
    echo "** Installing $GEM"
    $SUDO gem install $GEM $GEM_OPTIONS
  fi
  ((gi++))
done
$SUDO gem install $GEMS $GEM_OPTIONS

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

if command_exists port
then
  echo "*** Ports"
  $SUDO port install $PORTS
fi

if command_exists yum
then
  echo "*** RPMs"
  $SUDO yum install $RPMS
fi
