:- module dependency.


:- interface.

:- import_module
    json,
    map,
    string.

:- func deps_from_json(json.value) = map(string, string) is semidet.


:- implementation.

deps_from_json(JsonVal) = DepMap :-
    JsonVal = json.object(DepObj),
    map.map_values_only(json.get_string, DepObj, DepMap).
