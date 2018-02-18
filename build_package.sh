#!/bin/bash
output="mmc --make $1 --grade hlc.gc"
for i in "${@:2}"
do 
   output+=" --mld .packages/$i/lib/mercury --ml $i"
done
echo $output
$output
cd ../../..
