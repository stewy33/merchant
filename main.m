:- module main.
:- interface.

:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module
    bool,
    char,
    getopt,
    list,
    maybe,
    string.

:- import_module
    init_package,
    install_packages,
    manifest,
    util.

main(!IO) :-
    handle_command_line_args(MaybeOptionTable, !IO),
    (
      MaybeOptionTable = ok(OptionTable),

      getopt.lookup_bool_option(OptionTable, help, Help),
      (
        Help = yes,
        usage(!IO)
      ;
        Help = no
      ),

      getopt.lookup_bool_option(OptionTable, init, Init),
      (
        Init = yes,
        init_package(!IO)
      ;
        Init = no
      ),

      getopt.lookup_bool_option(OptionTable, install, Install),
      (
        Install = yes,
        install_packages(!IO)
      ;
        Install = no
       )
    ;
      MaybeOptionTable = error(OptionErrorMsg),
      string.format("error: %s.\n", [s(OptionErrorMsg)], ErrorMsg),
      util.io_write_error(ErrorMsg, !IO)
    ).

:- pred handle_command_line_args(maybe_option_table(option)::out, io::di, io::uo) is det.
handle_command_line_args(MaybeOptionTable, !IO) :-
    io.command_line_arguments(Args, !IO),
    OptionOps = option_ops_multi(
        short_option,
        long_option,
        option_default
    ),
    getopt.process_options(OptionOps, Args, NonOptionArgs, MaybeOptionTable).

:- pred usage(io::di, io::uo) is det.
usage(!IO) :-
   util.io_write_error("help message\n", !IO). 

:- type option ---> init
               ;    install
               ;    help.

:- pred short_option(char::in, option::out) is semidet.
short_option('i', install).
short_option('h', help).

:- pred long_option(string::in, option::out) is semidet.
long_option("init", init).
long_option("install", install).
long_option("help", help).

:- pred option_default(option::out, option_data::out) is multi.
option_default(init, bool(no)).
option_default(install, bool(no)).
option_default(help, bool(no)).
