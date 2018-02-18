# hophacks spring 2018

![merchant-logo](merchant-logo.png "Merchant Logo")

# ## A package manager for the Mercury logic programming language.

Commands:

    --init
        creates a blank manifest file and a ".package" directory
    
    --install
        installs all dependencies specified in the manifest
        using mmc --make
    
    --build
        builds your project using the dependencies downloaded
        by the package manager with mmc --make
    
    --help
        returns a help message


Installation

Recommended:

```bash
git clone https://github.com/stewy33/hophacks2018
./hophacks2018
```



cd into the "hophacks2018" folder then run the 
command 'chmod +x install_merchant.sh' then run './install_merchant.sh'
afterwards, you should be able to use merchant commands.

Alternatively,we provided experimental binaries for Linux and Mac.

ALSO: make sure you have install_packages.sh and build_libraries.sh
        in the project folder before running the merchant command

NOTE: this project has never been tested on Windows.  Mac and Linux
only

If you're compiling from source,
This project depends on juliensf's json parser:
https://github.com/juliensf/mercury-json


