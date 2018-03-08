:- module command_configure.


:- interface.

:- import_module
    io,
    list,
    string.

:- pred command_configure(list(string)::in, io::di, io::uo) is det.

:- implementation.

:- import_module
    dir,
    json,
    maybe.

:- import_module
    config,
    util.

command_configure(_, !IO) :-
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
    ).

