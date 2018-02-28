:- module command_configure.


:- interface.

:- import_module
    io,
    list,
    string.

:- pred command_configure(list(string)::in, io::di, io::uo) is det.


:- implementation.

:- import_module
    json,
    maybe.

:- import_module
    config,
    util.

command_configure(_, !IO) :-
    io.get_environment_var("HOME", MaybeHome, !IO),
    (
      MaybeHome = yes(Home),
      ConfigFile = Home ++ "/.merchant/config.json",
      io.open_output(ConfigFile, Res, !IO),
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
    ).

