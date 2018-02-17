:- module util.


:- interface.

:- import_module
    io,
    string.

:- pred io_write_error(string::in, io::di, io::uo) is det.


:- implementation.

io_write_error(ErrorMsg, !IO) :-
    io.stderr_stream(Stderr, !IO),
    io.write_string(Stderr, ErrorMsg, !IO).
