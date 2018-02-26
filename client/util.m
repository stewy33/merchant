:- module util.


:- interface.

:- import_module
    io,
    list,
    string.

:- pred id(A::di, A::uo) is det.

:- pred system(string::in, io::di, io::uo) is det.

:- pred exec_commands(list(string)::in, io::di, io::uo) is det.

:- pred write_error(io.error::in, io::di, io::uo) is det.

:- pred write_error_string(string::in, io::di, io::uo) is det.

:- implementation.

id(!S).

:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo),
    [will_not_call_mercury, promise_pure], 
"
    system(String);
    IO = IO0;
").

exec_commands(Commands, !IO) :-
    util.system(string.join_list("\n", Commands), !IO).

write_error(Error, !IO) :-
    write_error_string(io.error_message(Error), !IO).

write_error_string(ErrorMsg, !IO) :-
    io.stderr_stream(Stderr, !IO),
    io.write_string(Stderr, ErrorMsg, !IO).
