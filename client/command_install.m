:- module command_install.

:- interface.

:- import_module
    io,
    list.

:- pred command_install(list(string)::in, io::di, io::uo) is det.


:- implementation.

:- import_module
    dir,
    map,
    maybe,
    stream,
    stream.string_writer,
    string,
    string.builder.

:- import_module
    command_init,
    manifest,
    config,
    util.

command_install(_, !IO) :-
    dir.current_directory(Res, !IO),
    (
      Res = ok(CurrentDir),
      manifest_from_file(CurrentDir ++ "/manifest.json", MaybeManifest, !IO),
      (
        MaybeManifest = ok(Manifest),

        % if .merchant directory already exists, nothing will happen
        dir.make_single_directory(CurrentDir ++ "/.merchant", _, !IO),

        config.get_config(Config, !IO),
        map.foldl(install_library(Config ^ default_install_profile, CurrentDir),
            Manifest ^ dependencies, !IO)
      ;
        MaybeManifest = error(_),
        init_package_first_warning(!IO)
      )
    ;
      Res = error(ErrorMsg),
      util.write_error(ErrorMsg, !IO)
    ).

:- pred install_deps(string, string, list(string), io, io).
:- mode install_deps(in, in, out, di, uo) is det.
install_deps(InstallProf, LibDir, DepNames, !IO) :-
    dir.make_directory(LibDir, _, !IO),
    manifest_from_file(LibDir ++ "/manifest.json", MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(install_library(InstallProf, LibDir), Manifest ^ dependencies, !IO),
      DepNames = map.keys(Manifest ^ dependencies)
    ;
      MaybeManifest = error(_),
      DepNames = []
    ).

:- pred install_library(string, string, string, string, io, io).
:- mode install_library(in, in, in, in, di, uo) is det.
install_library(InstallProf, PackageDir, LibName, LibUrl, !IO) :-
    LibDir = string.format("%s/.merchant/%s", [s(PackageDir), s(LibName)]),
    SrcDir = string.format("%s/src", [s(LibDir)]),
    dir.make_directory(LibDir, Res, !IO),
    (
      Res = ok,
      download_library(LibName, LibUrl, SrcDir, !IO),
      install_deps(InstallProf, SrcDir, DepNames, !IO),
      build_library(InstallProf, PackageDir, LibName, DepNames, !IO)
    ;
      Res = error(_)
    ).

:- pred download_library(string, string, string, io, io) is det.
:- mode download_library(in, in, in, di, uo) is det.
download_library(LibName, LibUrl, SrcDir, !IO) :-
    dir.make_single_directory(SrcDir, Res, !IO),
    (
      Res = ok,
      io.format("Downloading %s...\n", [s(LibName)], !IO),
      util.system(string.format("git clone %s %s --quiet",
          [s(LibUrl), s(SrcDir)]), !IO)
    ;
      Res = error(_) % package already downloaded
    ).

:- pred build_library(string, string, string, list(string), io, io).
:- mode build_library(in, in, in, in, di, uo) is det.
build_library(InstallProf, PackageDir, LibName, DepNames, !IO) :-
    MerchantDir = PackageDir ++ "/.merchant",
    S0 = string.builder.init,

    % add base command
    string.format(
        "mmc --make --install-prefix %s/%s lib%s.install %s",
        [s(MerchantDir), s(LibName), s(LibName), s(InstallProf)], BaseCommand),
    string_writer.print(builder.handle, BaseCommand, S0, S1),

    % add dependency flags
    list.foldl((
        pred(DepName::in, !.S::di, !:S::uo) is det :-
            string.format(" --mld %s/%s/lib/mercury --ml %s",
                    [s(MerchantDir), s(DepName), s(DepName)], LibOpts),
            string_writer.print(builder.handle, LibOpts, !S)
    ), DepNames, S1, S2),

    string_writer.print(builder.handle, " 2> /dev/null", S2, S),
    BuildCommand = builder.to_string(S),

    CDCommand = string.format("cd %s/%s/src", [s(MerchantDir), s(LibName)]),

    io.format("Building %s...\n", [s(LibName)], !IO),
    util.exec_commands([CDCommand, BuildCommand], !IO).
