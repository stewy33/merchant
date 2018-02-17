:- module mainmanifest.


:- interface.

:- import_module
    io.
:- import_module
    manifest,
    maybe.

:- pred return_manifest(maybe_error(manifest)::out, io::di, io::uo) is det.


:- implementation.

:- import_module
    string.
return_manifest(ManifestOut, !IO) :-
    manifest_from_file(ManifestOut, !IO),
    (
      ManifestOut = ok(Manifest),
      io_write_manifest(Manifest, !IO)
    ;
      ManifestOut = error(ErrorMsg),
      io.stderr_stream(Stderr, !IO),
      io.write_string(Stderr, ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).
