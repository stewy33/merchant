:- module install_packages.


:- interface.

:- import_module
    io.

:- pred install_packages(string::in, io::di, io::uo) is det.


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

install_packages(ManifestFile, !IO) :-
    manifest_from_file(ManifestFile, MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(clone_package, Manifest ^ dependencies, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).

:- pred install_package(string::in, string::in, io::di, io::uo) is det.
install_package(PackageName, PackageUrl, !IO) :-
    SrcDir = string.format("%s/%s", [s(PackageDir), s(PackageName)]),
    PackageDir = string.format(".packages/%s", [s(PackageName)]),
    dir.make_single_directory(PackageDir, Result, !IO),
    (
      Result = ok,
      util.system(string.format("git clone %s %s",
          [s(PackageUrl), s(SrcDir)]), !IO)
    ;
      Result = error(_)
    ),
    install_packages(string.format("%s/manifest.json", [s(SrcDir)]), !IO),
    util.system(string.format("./installing_files.sh %s", [s(PackageName)], !IO).
