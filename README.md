# hophacks spring 2018

![merchant-logo](merchant-logo.png "Merchant Logo")

## Merchant: A package manager for the Mercury logic programming language.

```bash
$ merchant

Usage: merchant <command> [options]

Global options:
-h, --help             Print this usage information.
    --version          Print merchant version.

Available commands:
  build       Build package with dependencies according to manifest.json.
  clean       rm those pesky *.mh and *.err files.
  configure   Configure merchant settings.
  deps        Print package dependencies.
  install     Install the current package's dependencies.
  run         Run an executable from a package.
  version     Print merchant version.
```


### Installation

```bash
$ git clone https://github.com/stewy33/hophacks2018
$ sh hophacks2018/install.sh
$ merchant configure --reset-config
```

### Typical usage

1. Inside project folder, generate manifest file with `merchant init`.
2. Edit `manifest.json` with project name, author, dependencies.
3. After each update to `manifest.json`, run `merchant install`, then `merchant build`.

### Structure of a Manifest file

```json
{
    "name": "test",
    "author": "package_author",

    "dependencies": {
        "mercury_json": "https://github.com/stewy33/mercury-json"
    }
}
```

NOTE: this project has never been tested on Windows.  Mac and Linux
only