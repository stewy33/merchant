:- module parse.


:- interface.

:- import_module
    io.

:- pred main(io::di, io::uo) is det.


:- implementation.

:- import_module
    json,
    list,
    maybe,
    stream,
    string.


:- type manifest ---> manifest( name :: string,
                                
                                dependencies :: string ).

:- func manifest_from_json(json.value) = maybe_error(manifest).
manifest_from_json(Val) = ok(manifest("n", "d")).

main(!IO) :-
   io.open_input("manifest.json", MaybeFile, !IO),
   (
      MaybeFile = ok(InputFile),
      json.init_reader(InputFile, Reader, !IO),
      json.read_value(Reader, ValueResult, !IO),
      io.close_input(InputFile, !IO),

      (
        ValueResult = ok(Value),
        ManifestResult = manifest_from_json(Value),
        (
          ManifestResult = ok(Manifest),
          io.format("Name: %s, Deps: %s\n", [s(Manifest ^ name), s(Manifest ^ dependencies)], !IO)
        ;
          ManifestResult = error(_)
        )
      ;
        ValueResult = eof,
        io.write_string("Unexpected end-of-file\n", !IO)
      ;
        ValueResult = error(JsonError),
        io.write_string("Other Error\n", !IO)
      )
   ;
      MaybeFile = error(ErrorCode)
   ).
