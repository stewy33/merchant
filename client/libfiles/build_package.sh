#!/bin/bash

package_name=$1
dependencies=${@:2}

output="mmc --make $package_name --mercury-linkage static --grade hlc.gc"
for i in $dependencies
do 
   output+=" --mld .merchant/$i/lib/mercury --ml $i"
done

eval $output
