:- module config.


:- interface.

:- import_module
    json,
    io,
    map,
    string.

:- type config
    ---> config( install_profiles :: map(string, string),
                 build_profiles :: map(string, string) ).

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
            % install_profiles
            map.from_assoc_list([
                "default" - "--no-libgrade --libgrade none.gc.decldebug.stseg",
                "dev" - "--no-libgrade --libgrade none.gc.decldebug.stseg"
            ]),
            % build_profiles
            map.from_assoc_list([
                "default" - "--grade none.gc.decldebug.stseg",
                "dev" - "--grade none.gc.decldebug.stseg"
            ])).

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

          map.search(OuterObj, "install_profiles") = json.object(InsObj),
          map.map_values_only(json.get_string, InsObj, InsProfs),

          map.search(OuterObj, "build_profiles") = json.object(BuildObj),
          map.map_values_only(json.get_string, BuildObj, BuildProfs)

        then
          ok(config(InsProfs, BuildProfs))
        else
          error("Warning, malformed config.json.")
        )
].

:- instance json.to_json(config) where [
    to_json(Config) = json.det_make_object([

        "install_profiles" - json.object(
            map.map_values_only(func(Str) = json.string(Str),
                Config ^ install_profiles)),

        "build_profiles" - json.object(
            map.map_values_only(func(Str) = json.string(Str),
                Config ^ build_profiles))
        ])
].
