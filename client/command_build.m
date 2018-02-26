:- module command_build.


:- interface.

:- import_module
    io,
    list.

:- pred command_build(list(string)::in, io::di, io::uo) is det.


:- implementation.

:- import_module
    list,
    map,
    maybe,
    stream,
    stream.string_writer,
    string,
    string.builder.

:- import_module
    manifest,
    util.

command_build(Args, !IO) :-
    manifest_from_file("manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      exec_build(Manifest, Args, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      util.write_error_string(ErrorMsg, !IO)
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
    
    util.system(builder.to_string(S), !IO).
