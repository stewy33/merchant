:- module util.


:- interface.

:- import_module
    io,
    json,
    list,
    maybe,
    string.

:- pred id(A::di, A::uo) is det.
:- func id(A) = A.  
:- pred read_json_from_file(string, maybe_error(json.value), io, io) is det.
:- mode read_json_from_file(in, out, di, uo) is det.

:- pred write_error(io.error::in, io::di, io::uo) is det.

:- pred write_error_string(string::in, io::di, io::uo) is det.

:- pred write_error_msg(string::in, io::di, io::uo) is det.

:- pred system(string::in, io::di, io::uo) is det.

:- pred exec_commands(list(string)::in, io::di, io::uo) is det.


:- implementation.

:- import_module
    stream.

id(!S).
id(A) = A.

read_json_from_file(FileName, JsonResult, !IO) :- 
    io.open_input(FileName, MaybeFile, !IO),
    (
      MaybeFile = ok(InputFile),
      json.init_reader(InputFile, Reader, !IO),
      json.read_value(Reader, ValueResult, !IO),
      io.close_input(InputFile, !IO),

      (
        ValueResult = ok(Value),
        JsonResult = ok(Value)
      ;
        ValueResult = eof,
        JsonResult = error("error: unexpected end-of-file\n")
      ;
        ValueResult = error(JsonError),
        JsonResult = error(stream.error_message(JsonError))
      )
    ;
      MaybeFile = error(ErrorCode),
      JsonResult = error(stream.error_message(ErrorCode))
    ).

write_error(Error, !IO) :-
    write_error_string(io.error_message(Error), !IO).

write_error_string(ErrorMsg, !IO) :-
    io.stderr_stream(Stderr, !IO),
    io.write_string(Stderr, ErrorMsg, !IO).

write_error_msg(ErrorMsg, !IO) :-
    ErrorStr = string.format("error: %s.\n", [s(ErrorMsg)]),
    write_error_string(ErrorStr, !IO).

:- pragma foreign_proc("C", system(String::in, IO0::di, IO::uo),
    [will_not_call_mercury, promise_pure],
"
    system(String);
    IO = IO0;
").

exec_commands(Commands, !IO) :-
    util.system(string.join_list("\n", Commands), !IO).
