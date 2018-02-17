:- module main.
:- interface.

:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module 
    map,
    stream,
    string.

:- import_module
    mainmanifest,
    manifest,
    maybe.

:- pred system(string::in, io::di, io::uo) is det.
:- pred do_system_stuff(string::in, string::in, io::di, io::uo) is det.
:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo), [will_not_call_mercury, promise_pure], 
    "
      system(String);
    ").

main(!IO) :-
    return_manifest(MaybeManifest, !IO),
    ( MaybeManifest = ok(Manifest),
      foldl(do_system_stuff,
            Manifest^dependencies, !IO)
    ;
      MaybeManifest = error(Error),
      io.set_exit_status(1, !IO)
    ).

do_system_stuff(Key, Value, !IO) :-
    system("git clone " ++ Value, !IO).
 
