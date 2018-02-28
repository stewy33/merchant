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
                    dependencies :: map(string, string) ).

:- pred manifest_from_file(string::in, maybe_error(manifest)::out, io::di, io::uo) is det.

:- implementation.

:- import_module
    list,
    json,
    stream.

:- import_module
    dependency,
    util.

manifest_from_file(FileName, MaybeManifest, !IO) :-
    util.read_json_from_file(FileName, MaybeJson, !IO),
    (
      MaybeJson = ok(Val),
      MaybeManifest = from_json(Val)
    ;
      MaybeJson = error(Error),
      MaybeManifest = error(Error)
    ).

:- instance from_json(manifest) where [
    from_json(JsonVal) =
        ( if
          JsonVal = json.object(OuterObj),
          map.search(OuterObj, "name") = json.string(Name),
          map.search(OuterObj, "author") = json.string(Author),
          Deps = deps_from_json(map.search(OuterObj, "dependencies"))
        then
          ok(manifest(Name, Author, Deps))
        else
          error("There is a syntax error.")
        )
].
