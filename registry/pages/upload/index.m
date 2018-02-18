:- module index.


:- interface.

:- import_module
    io.

:- pred main(io::di, io::uo) is det.


:- implementation.

:- import_module
    assoc_list,
    cgi,
    list,
    maybe,
    pair,
    string.

main(!IO) :-
    cgi.get_form(MaybeData, !IO),
    (
      MaybeData = yes(FormData),
      io_write_assoc_list(FormData, !IO)
    ;
      MaybeData = no
    ).
 
:- pred io_write_assoc_list(assoc_list(string, string)::in, io::di, io::uo) is det.
io_write_assoc_list(List, !IO) :-
    io.write_list(List, ", ", io_write_pair, !IO).
    
:- pred io_write_pair(pair(string, string)::in, io::di, io::uo) is det.
io_write_pair(Pair, !IO) :-
    io.format("(%s, %s)", [s(fst(Pair)), s(snd(Pair))], !IO).
