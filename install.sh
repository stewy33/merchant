sudo echo -n

scriptdir="$(command dirname -- "${0}")"

cd $scriptdir/client
mmc --make merchant ${@}

printf "\nCopying merchant executable to /usr/local/bin/merchant...\n"
sudo cp merchant /usr/local/bin/
sudo chmod +x /usr/local/bin/merchant

printf "Configuring...\n"

printf "Done.\n"
printf "run \"merchant configure --reset-config\" to generate user config.\n"
