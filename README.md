![merchant-logo](merchant-logo.png "Merchant Logo")

## Merchant: A package manager for the Mercury logic programming language.

Merchant is a command line tool that downloads your [Mercury](http://mercurylang.org/) project's library dependencies and compiles your project.



### Installing Merchant

```bash
$ git clone https://github.com/stewy33/hophacks2018
$ sh hophacks2018/install.sh
```

Test that Merchant is installed by running:

```bash
$ merchant version
```



Create a default config:

```bash
$ merchant configure --reset-config
```

This creates a platform-specific global configuration file at `~/.merchant/config.json`, like the one below:

```json
{
    // default config file for OSX
    "build_profiles" : {
        // arguments before "--" are passed to "merchant build", everything after is passed to the mmc compiler
        "default" : "-- --grade none.gc.decldebug.stseg",
        "dev" : "-- --grade none.gc.decldebug.stseg --opt-level 0"
    },
    
    "install_profiles" : {
        "default" : "-- --no-libgrade --libgrade none.gc.decldebug.stseg",
        "dev" : "-- --no-libgrade --libgrade none.gc.decldebug.stseg --opt-level     0"
    }
}
```

The config file is editable, and sets default installation and build profiles. If you create a new build profile, called `production` for example, you could build your project with it by running:

```bash
$ merchant build --profile production
```

You can use the config file to set install and build options per system.



### Using Merchant

#### Basic Usage

1. Inside project folder, generate manifest file with `merchant init`.
2. Edit `manifest.json` with project name, author, dependencies.
3. After each update to `manifest.json`, run `merchant install`, and `merchant build` to compile the project.

#### Example Manifest file

```json
{
    "name": "test", // should match name of main module
    "author": "Stewy Slocum",

    "dependencies": {
        "mercury_json": "https://github.com/stewy33/mercury-json"
    }
}
```



NOTE: This project has only been tested on Mac and Linux, though it will probably work on Windows with Cygwin or Ubuntu shell.