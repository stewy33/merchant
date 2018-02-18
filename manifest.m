:- module manifest.


:- interface.

:- import_module
    io,
    map,
    maybe,
    string.

:- type manifest
    ---> manifest(  name :: string,
                    author :: string,
                    dependencies :: map(string,string) ).

:- pred manifest_from_file(string::in, maybe_error(manifest)::out, io::di, io::uo) is det.

:- pred io_write_manifest(manifest::in, io::di, io::uo) is det.

:- implementation.

:- import_module
    json,
    list,
    stream.

manifest_from_file(FileName, MaybeManifest, !IO) :-
    read_json_from_file(FileName, MaybeJson, !IO),
    (
      MaybeJson = ok(Val),
      MaybeManifest = manifest_from_json(Val)
    ;
      MaybeJson = error(Error),
      MaybeManifest = error(Error)
    ).

:- func object_to_string_map(json.object) = map(string, string) is semidet.
object_to_string_map(Obj) = Map :-
    map.map_values_only(json.get_string, Obj, Map).

:- func manifest_from_json(json.value) = maybe_error(manifest).
manifest_from_json(JsonVal) =
    ( if
         JsonVal = json.object(OuterObj),
         map.search(OuterObj, "name") = json.string(Name),
         map.search(OuterObj, "author") = json.string(Author),
         map.search(OuterObj, "dependencies") = json.object(DepMap),
         object_to_string_map(DepMap) = Dependencies
      then
         ok(manifest(Name, Author, Dependencies))
       else
         error("There is a syntax error.")
     ).


:- pred read_json_from_file(string::in, maybe_error(json.value)::out, io::di, io::uo) is det.
read_json_from_file(FileName, JsonResult, !IO) :- 
    io.open_input(FileName, MaybeFile, !IO),
    (
      MaybeFile = ok(InputFile),
      json.init_reader(InputFile, Reader, !IO),
      json.read_value(Reader, ValueResult, !IO),
      io.close_input(InputFile, !IO),

      % check that manifest file is valid json
      (
        ValueResult = ok(Value),
        JsonResult = ok(Value)
      ;
        (
          ValueResult = eof,
          JsonResult = error("error: unexpected end-of-file\n")
        ;
          ValueResult = error(JsonError),
          JsonResult = error(stream.error_message(JsonError))
        )
      )
    ;
      MaybeFile = error(ErrorCode),
      JsonResult = error(stream.error_message(ErrorCode))
    ).

io_write_manifest(Manifest, !IO) :-
      io.format("Name: %s\nAuthor: %s\n", [s(Manifest ^ name), s(Manifest ^ author)], !IO),
      map.foldl(write_map2, Manifest ^ dependencies, !IO).

:- pred write_map2(string::in, string::in, io::di, io::uo) is det.
write_map2(K, V, !IO) :-
    io.format("Key: %s, Value: %s\n", [s(K), s(V)], !IO).
