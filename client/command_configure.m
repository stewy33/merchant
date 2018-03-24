:- module command_configure.


:- interface.

:- import_module
    io,
    list,
    string.

:- pred command_configure(list(string)::in, io::di, io::uo) is det.

:- implementation.

:- import_module
    bool,
    char,
    dir,
    getopt,
    json,
    maybe.

:- import_module
    config,
    util.

:- type option ---> help
               ;    reset_config.

:- pred short_option(char::in, option::out) is semidet.
short_option('h', help).

:- pred long_option(string::in, option::out) is semidet.
long_option("help", help).
long_option("reset-config", reset_config).

:- pred option_default(option::out, option_data::out) is multi.
option_default(help, bool(no)).
option_default(reset_config, bool(no)).

command_configure(Args, !IO) :-
    OptionOps = option_ops_multi(short_option, long_option, option_default),
    getopt.process_options(OptionOps, Args, _, MaybeOptTable),
    (
      MaybeOptTable = ok(OptTable),

      getopt.lookup_bool_option(OptTable, help, Help),
      (
        Help = yes,
        usage(!IO)
      ;
        Help = no
      ),

      getopt.lookup_bool_option(OptTable, reset_config, ResetConfig),
      (
        ResetConfig = yes,
        io.get_environment_var("HOME", MaybeHome, !IO),
        (
          MaybeHome = yes(Home),
          dir.make_single_directory(Home ++ "/.merchant", _, !IO),
          io.open_output(Home ++ "/.merchant/config.json", Res, !IO),
          (
            Res = ok(File),
            config.get_OS_default_config(Config, !IO),
            write_pretty(File, json.to_json(Config), !IO),
            io.close_output(File, !IO)
          ;
            Res = error(ErrorCode),
            util.write_error(ErrorCode, !IO)
          )
        ;
          MaybeHome = no,
          util.write_error_string(
            "$HOME environment variable not set, cannot find ~/.merchant/config.json.\n",
            !IO)
        )
      ;
        ResetConfig = no
      )
    ;
      MaybeOptTable = error(OptErrorMsg),
      util.write_error_msg(OptErrorMsg, !IO)
    ).

:- pred usage(io::di, io::uo) is det.
usage(!IO) :-
    util.write_error_string(
"
Usage: merchant configure [options]
-h, --help          Print this usage information.

    --reset-config  Overwrite ~/.merchant/config.json with OS default.

"
    , !IO).
