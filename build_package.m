:- module build_package.


:- interface.

:- import_module
    io.

:- pred build_package(io::di, io::uo) is det.


:- implementation.

build_package(!IO).
