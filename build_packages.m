:- module build_packages.


:- interface.

:- import_module
    io.
    
:- pred build_packages(io::di, io::uo) is det. 

:- implementation.

:- import_module
    dir.

:- import_module
    manifest.

build_packages(!IO) :-
    manifest_from_file(MaybeManifest, !IO),
    (
        MaybeManifest = ok(Manifest),
        map.foldl(add_build_command_)
    )
