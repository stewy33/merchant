#!/bin/bash

sudo echo -n

scriptdir="$(command dirname -- "${0}")"

cd $scriptdir/client
mmc --make merchant

sudo cp merchant /usr/local/bin/

printf "\nDone\n"
