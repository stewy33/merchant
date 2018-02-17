:- module install_packages.


:- interface.

:- import_module
    io.

:- pred install_packages(io::di, io::uo) is det.


:- implementation.

:- import_module
    map,
    maybe,
    string.

:- import_module
    manifest,
    util.

install_packages(!IO) :-
    manifest_from_file(MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(install_package, Manifest ^ dependencies, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).

:- pred install_package(string::in, string::in, io::di, io::uo) is det.
install_package(Key, Value, !IO) :-
    system("git clone " ++ Value, !IO).

:- pred system(string::in, io::di, io::uo) is det.
:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo), [will_not_call_mercury, promise_pure], 
    "
      system(String);
    ").
