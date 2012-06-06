#!/usr/bin/env bash

GEMS="awestruct nokogiri json git vpim rest-client pygments.rb"
EGGS="pygments"
PORTS="asciidoc"
RPMS=$PORTS

command_exists () {
    type "$1" &> /dev/null ;
}

echo "**** Setting up necessary Gems, Eggs and [RPMs|Mac Ports] for the jdf site"

echo "*** Gems"
sudo gem install $GEMS $GEM_OPTIONS

e=${#EGGS[@]}
ei=0
echo "*** Eggs"
while [ "$ei" -lt "$e" ]
do
  EGG=${EGGS[ei]}
  echo "** Installing $EGG"
  sudo easy_install --upgrade $EGG
  ((ei++))
done

if command_exists port
then
  echo "*** Ports"
  sudo port install $PORTS
fi

if command_exists yum
then
  echo "*** RPMs"
  sudo yum install $RPMS
fi
