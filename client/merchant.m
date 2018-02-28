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
    command_build,
    command_configure,
    command_deps,
    command_init,
    command_install,
    manifest,
    util.

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (
      Args = [],
      usage(!IO)
    ;
      Args = [Arg1 | RemainingArgs],
      (
        if Arg1 = "build"
        then command_build(RemainingArgs, !IO)

        else ( if Arg1 = "clean"
        then util.system("rm *.mh *.err", !IO)

        else ( if Arg1 = "configure"
        then command_configure(RemainingArgs, !IO)

        else ( if Arg1 = "deps"
        then command_deps(!IO)

        else ( if Arg1 = "init"
        then command_init(!IO)

        else ( if Arg1 = "install"
        then command_install(RemainingArgs, !IO)

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
      ))))))))
    ).

/*main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (
      Args = [],
      usage(!IO)
    ;
      Args = [Arg1 | RemainingArgs],
      ( if
        (
          Arg1 = "build",
          command_build(RemainingArgs, !IO)
        ;
          Arg1 = "clean",
          util.system("rm *.mh *.err", !IO)
        ;
          Arg1 = "configure",
          command_configure(RemainingArgs, !IO)
        ;
          Arg1 = "deps",
          command_deps(!IO)
        ;
          Arg1 = "init",
          command_init(!IO)
        ;
          Arg1 = "install",
          command_install(RemainingArgs, !IO)
        ;
          Arg1 = "help", usage(!IO)
        ; Arg1 = "--help", usage(!IO)
        ; Arg1 = "-h", usage(!IO)
        ;
          Arg1 = "version", version(!IO)
        ; Arg1 = "--version", version(!IO)
        )
        then util.id(!IO)
        else
          ErrorMsg = string.format("error: unrecognized option \"%s\"\n",
              [s(list.det_head(Args))]),
          util.write_error_string(ErrorMsg, !IO),
          usage(!IO)
      )
    ).*/

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
  clean       rm those pesky *.mh and *.err files.
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
