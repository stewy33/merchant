#!/bin/bash

prfxdir=$(pwd)/.packages/$1
output="mmc --make --no-libgrade --libgrade hlc.gc --install-prefix $prfxdir lib$1.install"

for i in "${@:2}"
do 
   libdir=$(pwd)/.packages/$i/lib/mercury
   output+=" --mld $libdir --ml $i"
done
echo $output
cd .packages/$1/$1
pwd
eval $output
cd ../../..
