# hophacks spring 2018

![merchant-logo](merchant-logo.png "Merchant Logo")

## Merchant: A package manager for the Mercury logic programming language.

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


### Installation

Easy Installation

```bash
git clone https://github.com/stewy33/hophacks2018
./hophacks2018/install.sh
```


Alternatively, we provide experimental binaries for Linux and Mac.

ALSO: make sure you have install_packages.sh and build_libraries.sh
        in the project folder before running the merchant command

NOTE: this project has never been tested on Windows.  Mac and Linux
only