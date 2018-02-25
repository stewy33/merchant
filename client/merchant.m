:- module merchant.


:- interface.

:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module
    bool,
    char,
    dir,
    getopt,
    list,
    maybe,
    string.

:- import_module
    build_package,
    dependency,
    init_package,
    install_deps,
    manifest,
    util.

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (
      Args = [Arg1 | RemainingArgs],
      (
        if Arg1 = "build"
        then build_package(!IO)

        else ( if Arg1 = "deps"
        then list_dependencies(!IO)

        else ( if Arg1 = "init"
        then init_package(!IO)

        else ( if Arg1 = "install"
        then install_deps(RemainingArgs, !IO)

        else ( if Arg1 = "help"
                ; Arg1 = "--help"
                ; Arg1 = "-h"
        then usage(!IO)

        else ( if Arg1 = "version"
                ; Arg1 = "--version"
        then version(!IO)

        else
          ErrorMsg = string.format("error: unrecognized option \"%s\"\n",
              [s(list.det_head(Args))]),
          util.write_error_string(ErrorMsg, !IO),
          usage(!IO)
      ))))))
    ;
      Args = [],
      usage(!IO)
    ).

:- pred usage(io::di, io::uo) is det.
usage(!IO) :-
    util.write_error_string(
"
Merchant: A package manager for the Mercury logic programming language.

Usage: merchant <command> [arguments]

Global options:
-h, --help             Print this usage information.
    --version          Print merchant version.

Available commands:
  build       Build package with dependencies according to manifest.json.
  deps        Print package dependencies.
  install     Install the current package's dependencies.
  help        Display help information for merchant.
  run         Run an executable from a package.
  version     Print merchant version.

"
    , !IO).

:- pred version(io::di, io::uo) is det.
version(!IO) :-
    io.write_string("Merchant 0.0.1\n", !IO).
