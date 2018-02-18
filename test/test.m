:- module test.


:- interface.

:- import_module
    io.

:- pred main(io::di, io::uo) is det.


:- implementation.

:- import_module mercury_json.

main(!IO) :-
    io.write_string("Hello\n", !IO).
