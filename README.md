# hophacks spring 2018

![merchant-logo](merchant-logo.png "Merchant Logo")

=======================================================================
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
========================================================================

Installation

we provided experimental binaries for Linux and Mac.  NOTE: This project
has not been tested on windows.

To use, place the "build_package.sh", "install_libraries.sh" and
the binary (depending on your operating system) in the project
folder.  Run with "./main -- <command>".

If you're compiling from source,
This project depends on juliensf's json parser:
https://github.com/juliensf/mercury-json


