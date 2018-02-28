# hophacks spring 2018

![merchant-logo](merchant-logo.png "Merchant Logo")

## Merchant: A package manager for the Mercury logic programming language.

```bash
$ merchant

Usage: merchant <command> [arguments]

Global options:
-h, --help             Print this usage information.
    --version          Print merchant version.

Available commands:
  build       Build package with dependencies according to manifest.json.
  clean       rm those pesky *.mh and *.err files.
  deps        Print package dependencies.
  install     Install the current package's dependencies.
  help        Display help information for merchant.
  run         Run an executable from a package.
  version     Print merchant version.
```


### Installation

```bash
git clone https://github.com/stewy33/hophacks2018
sh hophacks2018/install/install.sh
```

NOTE: this project has never been tested on Windows.  Mac and Linux
only
