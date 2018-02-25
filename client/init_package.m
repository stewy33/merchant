:- module init_package.


:- interface.

:- import_module
    io.

:- pred init_package(io::di, io::uo) is det.

:- pred init_package_first_warning(io::di, io::uo) is det.


:- implementation.

:- import_module
    dir.

:- import_module
    manifest,
    util.

init_package(!IO) :-
    io.open_output("manifest.json", MaybeFile, !IO),
    (
      MaybeFile = ok(File),
      io.write_string(File, default_manifest, !IO)
    ;
      MaybeFile = error(_)
    ).
 
:- func default_manifest = string.
default_manifest =
"{
    \"name\": \"package_name\",
    \"author\": \"package_author\",
    \"dependencies\": {
    }
}\n".

init_package_first_warning(!IO) :-
    util.write_error_string(
"
Manifest file does not exist, try running \"merchant init\" first.
"
    , !IO).
