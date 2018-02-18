#!/bin/bash
output="mmc --make --no-libgrade --libgrade hlc.gc --install-prefix ../ lib$1.install"
for i in "${@:2}"
do 
   output+=" --mld ../../$i/lib/mercury --ml $i"
done
echo $output
cd .packages/$1/$1
pwd
$output
cd ../../..
