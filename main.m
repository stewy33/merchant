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
    manifest.

:- pred system(string::in, io::di, io::uo) is det.
:- pred do_system_stuff(string::in, string::in, io::di, io::uo) is det.
:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo), [will_not_call_mercury, promise_pure], 
    "
      system(String);
    ").

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
      )
    ;
      MaybeOptionTable = error(OptionErrorMsg),
      string.format("error: %s.\n", [s(OptionErrorMsg)], ErrorMsg),
      io_write_error(ErrorMsg, !IO)
    ).
    /*manifest_from_file(MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      io_write_manifest(Manifest, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).*/

:- pred io_write_error(string::in, io::di, io::uo) is det.
io_write_error(ErrorMsg, !IO) :-
    io.stderr_stream(Stderr, !IO),
    io.write_string(Stderr, ErrorMsg, !IO).

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
   io_write_error("help message\n", !IO). 

:- type option ---> init
               ;    help.

:- pred short_option(char::in, option::out) is semidet.
short_option('h', help).

:- pred long_option(string::in, option::out) is semidet.
long_option("init", init).
long_option("help", help).

:- pred option_default(option::out, option_data::out) is multi.
option_default(init, bool(no)).
option_default(help, bool(no)).
