#!/bin/bash

package_name=$1
dependencies=${@:2}

prefixdir=$(pwd)/.merchant/$package_name
output="mmc --make --no-libgrade --libgrade hlc.gc
    --install-prefix $prefixdir lib$package_name.install"

for i in $dependencies
do
   libdir=$(pwd)/.merchant/$i/lib/mercury
   output+=" --mld $libdir --ml $i"
done

cd $prefixdir/src
eval $output &> /dev/null
