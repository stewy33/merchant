:- module main.


:- interface.

:- import_module
    io.

:- pred main(io::di, io::uo) is det.


:- implementation.

:- import_module
    maybe,
    string.

:- import_module
    manifest.

main(!IO) :-
    manifest_from_file(MaybeManifest, !IO),
    (
      MaybeManifest = ok(Manifest),
      io_write_manifest(Manifest, !IO)
    ;
      MaybeManifest = error(ErrorMsg),
      io.stderr_stream(Stderr, !IO),
      io.write_string(Stderr, ErrorMsg, !IO),
      io.set_exit_status(1, !IO)
    ).
