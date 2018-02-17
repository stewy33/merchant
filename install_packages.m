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
/*
install_packages(!IO) :-
    manifest_from_file(MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      map.foldl(clone_package, Manifest ^ dependencies, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io_write_error(ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).

:- pred clone_package(string::in, string::in, io::di, io::uo) is det.
clone_package(Key, Value, !IO) :-
    system("git clone " ++ Value, !IO).
*/
install_packages(!IO) :-
    Key = "json",
    system("./installing_files.sh " ++ Key, !IO).

:- pred system(string::in, io::di, io::uo) is det.
:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo), [will_not_call_mercury, promise_pure], 
    "
      system(String);
    ").
