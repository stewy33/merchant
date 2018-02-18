:- module install_packages.


:- interface.

:- import_module
    io.

:- pred install_packages(string::in, string::out, io::di, io::uo) is det.


:- implementation.

:- import_module
    dir,
    list,
    map,
    maybe,
    string.

:- import_module
    manifest,
    util.

install_packages(ManifestFile, DepArgs, !IO) :-
    manifest_from_file(ManifestFile, MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(install_package, Manifest ^ dependencies, !IO),
      DepArgs = map.foldl(concat_to_string, Manifest ^ dependencies, "")
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO),
      DepArgs = ""
    ).
 
:- func concat_to_string(string, string, string) = string.
concat_to_string(PackageName, _, Acc) = PackageName ++ " " ++ Acc.

:- pred install_package(string::in, string::in, io::di, io::uo) is det.
install_package(PackageName, PackageUrl, !IO) :-
    SrcDir = string.format("%s/%s", [s(PackageDir), s(PackageName)]),
    PackageDir = string.format(".packages/%s", [s(PackageName)]),
    dir.make_single_directory(PackageDir, Result, !IO),
    (
      Result = ok,
      util.system(string.format("git clone %s %s",
          [s(PackageUrl), s(SrcDir)]), !IO),
      install_packages(string.format("%s/manifest.json", [s(SrcDir)]), DepArgs, !IO),
      util.system(string.format("./install_library.sh %s %s",
        [s(PackageName), s(DepArgs)]), !IO)
    ;
      Result = error(_)
    ).
