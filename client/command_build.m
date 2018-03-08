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
    util.

:- type option ---> profile
               ;    help
               ;    mmc_option.

:- pred short_option(char::in, option::out) is semidet.
short_option('h', help).

:- pred long_option(string::in, option::out) is semidet.
long_option("profile", profile).
long_option("help", help).
long_option("mmc_option", mmc_option).

:- pred option_default(option::out, option_data::out) is multi.
option_default(profile, string_special).
option_default(help, bool(no)).
option_default(mmc_option, accumulating([])).

:- func special_handler_from_config(config) =
    (pred(option, special_data,
          option_table(option), maybe_option_table(option))).
special_handler_from_config(Config) =
    (pred(profile::in, string(Profile)::in,
          OptTable0::in, MaybeOptTable::out) is semidet :-
     (
       if
           map.search(Config ^ build_profiles, Profile, ProfVal)
       then
           map.transform_value(
               (pred(Opts0::in, Opts::out) is det :-
                Opts =
                  ( if Opts0 = accumulating(OptsList)
                    then accumulating([ProfVal | OptsList])
                    else Opts0 )),
               mmc_option, OptTable0, OptTable),
           MaybeOptTable = ok(OptTable)
       else
           ErrorMsg = string.format(
               "Profile %s not found in config.", [s(Profile)]),
           MaybeOptTable = error(ErrorMsg)
     )).

command_build(Args, !IO) :-
    manifest_from_file("manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      config.get_config(Config, !IO),

      OptionOps = option_ops_multi(short_option, long_option,
          option_default, special_handler_from_config(Config)),
      getopt.process_options(OptionOps, Args, _, MaybeOptTable),
      (
        MaybeOptTable = ok(OptTable),
        getopt.lookup_bool_option(OptTable, help, Help),
        (
          Help = yes,
          usage(!IO)
        ;
          Help = no,
          getopt.lookup_accumulating_option(OptTable, mmc_option, MmcOptions),
          exec_build(Manifest, MmcOptions, !IO)
        )
      ;
        MaybeOptTable = error(OptErrorMsg),
        ErrorMsg = string.format("error: %s.\n", [s(OptErrorMsg)]),
        util.write_error_string(ErrorMsg, !IO)
      )
    ;
      MaybeManifest = error(_),
      init_package_first_warning(!IO)
    ).

:- pred exec_build(manifest, list(string), io, io).
:- mode exec_build(in, in, di, uo) is det.
exec_build(Manifest, Args, !IO) :-
    S0 = string.builder.init,

    % add base command
    string.format(
        "mmc --make %s",
        [s(Manifest ^ name)], BaseCommand),
    string_writer.print(builder.handle, BaseCommand, S0, S1),

    % add other args
    ArgsStr = string.join_list(" ", ["" | Args]),
    string_writer.print(builder.handle, ArgsStr, S1, S2),

    % add dependency options
    map.foldl((
        pred(DepName::in, _::in, !.S::di, !:S::uo) is det :-
            string.format(" --mld .merchant/%s/lib/mercury --ml %s",
                    [s(DepName), s(DepName)], LibOpts),
            string_writer.print(builder.handle, LibOpts, !S)
    ), Manifest ^ dependencies, S2, S),

    io.write_string(builder.to_string(S) ++ "\n", !IO).

:- pred usage(io::di, io::uo).
usage(!IO) :-
    util.write_error_string(
"
Usage: merchant build [arguments]

"
    , !IO).
