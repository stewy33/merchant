:- module dependency.


:- interface.

:- import_module
    io.

:- pred list_dependencies(io::di, io::uo) is det.


:- implementation.

:- import_module
    dir,
    map,
    maybe,
    string.

:- import_module
    init_package,
    manifest,
    util.

list_dependencies(!IO) :-
    dir.current_directory(Res, !IO),
    (
      Res = ok(CurrentDir),
      manifest_from_file(CurrentDir ++ "/manifest.json", MaybeManifest, !IO),
      (
        MaybeManifest = ok(Manifest),
        map.foldl(
            (pred(DepName::in, _::in, di, uo) is det -->
                    io.write_string(DepName),
                    io.nl
            ), Manifest ^ dependencies, !IO)
      ;
        MaybeManifest = error(_),
        init_package_first_warning(!IO)
      )
    ;
      Res = error(ErrorMsg),
      util.write_error(ErrorMsg, !IO)
    ).
