:- module config.


:- interface.

:- import_module
    json,
    io,
    string.

:- type config
    ---> config( default_install_profile :: string,
                 default_build_profile :: string ).

:- pred get_config(config::out, io::di, io::uo) is det.

:- pred get_OS_default_config(config::out, io::di, io::uo) is det.

:- instance json.to_json(config).


:- implementation.

:- import_module
    list,
    map,
    maybe,
    pair,
    util.

get_config(Config, !IO) :-
    config_from_file(MaybeConfig, !IO),
    (
      MaybeConfig = ok(Config)
    ;
      MaybeConfig = error(ErrorMsg),
      ErrorStr = ErrorMsg ++
" Using OS default instead.
Try running \"merchant configure\" to reset ~/.merchant/config.json.\n",
      util.write_error_string(ErrorStr, !IO),
      get_OS_default_config(Config, !IO)
    ).

get_OS_default_config(Config, !IO) :-
    Config = config(
            % default_install_profile
            "--no-libgrade --libgrade none.gc.decldebug.stseg",
            % default_build_profile
            "--grade none.gc.decldebug.stseg" ).

:- pred config_from_file(maybe_error(config), io, io).
:- mode config_from_file(out, di, uo) is det.
config_from_file(MaybeConfig, !IO) :-
    io.get_environment_var("HOME", MaybeHome, !IO),
    (
      MaybeHome = yes(Home),
      util.read_json_from_file(Home ++ "/.merchant/config.json", MaybeJson, !IO),
      (
        MaybeJson = ok(Val),
        MaybeConfig = json.from_json(Val)
      ;
        MaybeJson = error(_),
        MaybeConfig = error("Warning, missing ~/.merchant/config.json.")
      )
    ;
      MaybeHome = no,
      MaybeConfig = error(
        "$HOME environment variable not set, cannot find ~/.merchant/config.json.")
    ).

:- instance json.from_json(config) where [
    from_json(JsonVal) =
        ( if
          JsonVal = json.object(OuterObj),
          map.search(OuterObj, "default_install_profile") = json.string(InsProf),
          map.search(OuterObj, "default_build_profile") = json.string(BuildProf)
        then
          ok(config(InsProf, BuildProf))
        else
          error("Warning, malformed ~/.merchant/config.json.")
        )
].

:- instance json.to_json(config) where [
    to_json(Config) = json.det_make_object([
        "default_install_profile" - json.string(Config ^ default_install_profile),
        "default_build_profile" - json.string(Config ^ default_build_profile)
        ])
].
