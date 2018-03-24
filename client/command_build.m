:- module command_build.


:- interface.

:- import_module
    io,
    list.

:- pred command_build(list(string)::in, io::di, io::uo) is det.


:- implementation.

:- import_module
    bool,
    char,
    getopt,
    int,
    list,
    map,
    maybe,
    stream,
    stream.string_writer,
    string,
    string.builder.

:- import_module
    config,
    command_init,
    manifest,
    profile,
    util.

:- type option ---> help
               ;    profile.

:- pred short_option(char::in, option::out) is semidet.
short_option('h', help).
short_option('p', profile).

:- pred long_option(string::in, option::out) is semidet.
long_option("help", help).
long_option("profile", profile).

:- pred option_default(option::out, option_data::out) is multi.
option_default(profile, string("default")).
option_default(help, bool(no)).

command_build(Args, !IO) :-
    manifest_from_file("manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      config.get_config(Config, !IO),

      OptionOps = option_ops_multi(short_option, long_option, option_default),
      getopt.process_options(OptionOps, Args, _, MaybeOptTable0),
      (
        MaybeOptTable0 = ok(OptTable0),
        adjust_options_with_profile(OptionOps, profile,
            Config ^ build_profiles, OptTable0, MaybeOptTable, MmcOpts),
        (
          MaybeOptTable = ok(OptTable),

          getopt.lookup_bool_option(OptTable, help, Help),
          (
            Help = yes,
            usage(!IO)
          ;
            Help = no,
            exec_build(Manifest, string.join_list(" ", [MmcOpts]), !IO)
          )
        ;
          MaybeOptTable = error(ErrorMsg),
          util.write_error_msg(ErrorMsg, !IO)
        )
      ;
        MaybeOptTable0 = error(ErrorMsg),
        util.write_error_msg(ErrorMsg, !IO)
      )
    ;
      MaybeManifest = error(_),
      init_package_first_warning(!IO)
    ).

:- pred exec_build(manifest::in, string::in, io::di, io::uo) is det.
exec_build(Manifest, Args, !IO) :-
    S0 = string.builder.init,

    % add base command
    string.format(
        "mmc --make %s",
        [s(Manifest ^ name)], BaseCommand),
    string_writer.print(builder.handle, BaseCommand, S0, S1),

    % add other args
    string_writer.print(builder.handle, " " ++ Args, S1, S2),

    % add dependency options
    map.foldl((
        pred(DepName::in, _::in, !.S::di, !:S::uo) is det :-
            string.format(" --mld .merchant/%s/lib/mercury --ml %s",
                    [s(DepName), s(DepName)], LibOpts),
            string_writer.print(builder.handle, LibOpts, !S)
    ), Manifest ^ dependencies, S2, S),

    util.system(builder.to_string(S) ++ "\n", !IO).

:- pred usage(io::di, io::uo).
usage(!IO) :-
    util.write_error_string(
"
Usage: merchant build [options]
-h, --help     Print this usage information.

-p, --profile  Choose a specific build profile from ~/.merchant/config.json.

"
    , !IO).
