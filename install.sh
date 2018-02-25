#!/bin/bash

sudo echo -n

scriptdir="$(command dirname -- "${0}")"

cd $scriptdir/client
mmc --make merchant

printf "\nCopying files...\n"
sudo cp merchant /usr/local/bin/
sudo cp libfiles/* /usr/local/lib/merchant/

printf "\nDone\n"
