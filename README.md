# hophacks spring 2018
Merchant
====================================================================
Package manager for the Mercury logic programming language.

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
====================================================================
Installation

we provided experimental binaries for Linux and Mac.  This has not
been tested on Windows.  Make sure the "build_package.sh" and
"install_libraries.sh" are in your project folder along with the
binaries.

This project depends on juliensf's json parser:
https://github.com/juliensf/mercury-json


