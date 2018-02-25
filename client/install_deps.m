:- module install_deps.


:- interface.

:- import_module
    io,
    list.

:- pred install_deps(list(string)::in, io::di, io::uo) is det.


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

install_deps(_, !IO) :-
    dir.current_directory(Res, !IO),
    (
      Res = ok(CurrentDir),
      dir.make_single_directory(CurrentDir ++ "/.merchant", _, !IO),
      manifest_from_file(CurrentDir ++ "/manifest.json", MaybeManifest, !IO),
      (
        MaybeManifest = ok(Manifest),
        map.foldl(install_package(CurrentDir), Manifest ^ dependencies, !IO)
      ;
        MaybeManifest = error(_),
        init_package_first_warning(!IO)
      )
    ;
      Res = error(ErrorMsg),
      util.write_error(ErrorMsg, !IO)
    ).
 
:- pred install_deps_2(string::in, string::out, io::di, io::uo) is det.
install_deps_2(PackageDir, DepArgs, !IO) :-
    dir.make_directory(PackageDir, _, !IO),
    manifest_from_file(PackageDir ++ "/manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(install_package(PackageDir), Manifest ^ dependencies, !IO),
      DepArgs = map.foldl(concat_to_string, Manifest ^ dependencies, "")
    ;
      MaybeManifest = error(_),
      DepArgs = ""
    ).
 
:- func concat_to_string(string, string, string) = string.
concat_to_string(PackageName, _, Acc) = PackageName ++ " " ++ Acc.

:- pred install_package(string::in, string::in, string::in, io::di, io::uo) is det.
install_package(PackageDir, DepName, DepUrl, !IO) :-
    DepDir = string.format("%s/.merchant/%s", [s(PackageDir), s(DepName)]),
    SrcDir = string.format("%s/src", [s(DepDir)]),
    dir.make_single_directory(DepDir, Result, !IO),
    (
      Result = ok,
      util.system(string.format("git clone %s %s",
          [s(DepUrl), s(SrcDir)]), !IO),
      install_deps_2(SrcDir, DepArgs, !IO),
      util.system(string.format("/usr/local/lib/merchant/install_library.sh %s %s",
        [s(DepName), s(DepArgs)]), !IO)
    ;
      Result = error(_)
    ).
