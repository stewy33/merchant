:- module build_package.


:- interface.

:- import_module
    io.

:- pred build_package(io::di, io::uo) is det.


:- implementation.

:- import_module
    list,
    map,
    maybe,
    string.

:- import_module
    manifest,
    util.

build_package(!IO) :-
    manifest_from_file("manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      DepArgs = map.foldl(func(N, _, A) = N ++ " " ++ A,
        Manifest ^ dependencies, ""),
      util.system(string.format("./build_package.sh %s %s", [s(Manifest ^ name),
          s(DepArgs)]), !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO)
    ).
