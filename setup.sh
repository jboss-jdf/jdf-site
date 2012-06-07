#!/usr/bin/env bash

GEMS="awestruct nokogiri json git vpim rest-client pygments.rb"
EGGS=("pygments" "yuicompressor")
PORTS="asciidoc"
RPMS=$PORTS

if [ -z "$SUDO" ]; then
    SUDO="sudo"
fi


command_exists () {
    type "$1" &> /dev/null ;
}

echo "**** Setting up necessary Gems, Eggs and [RPMs|Mac Ports] for the jdf site"

echo "*** Gems"
cmd="$SUDO gem install $GEMS $GEM_OPTIONS"
echo $cmd
$cmd

e=${#EGGS[@]}
ei=0
echo "*** Eggs"
while [ "$ei" -lt "$e" ]
do
  EGG=${EGGS[ei]}
  echo "** Installing $EGG"
  $SUDO easy_install --upgrade $EGG
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
