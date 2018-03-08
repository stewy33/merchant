sudo echo -n

scriptdir="$(command dirname -- "${0}")"

cd $scriptdir/client
mmc --make merchant ${@}

sudo cp merchant /usr/local/bin/
sudo chmod +x /usr/local/bin/merchant

printf "\nDone\n"
