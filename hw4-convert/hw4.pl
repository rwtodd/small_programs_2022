% convert hyperReader 4 files to html

% read 64 bytes at a time, and keep adding until the last four bytes are not 00 00 00 00
read_64(IStrm, Bs, More) :- length(Bs, 60), maplist(get_byte(IStrm), Bs), !, length(LastFour,4),
  maplist(get_byte(IStrm), LastFour), !, (LastFour = [0,0,0,0] -> More = yes ; More = no).

read_chunks(IStrm, [C|Cs]) :- read_64(IStrm, C, More), !,
  (More = yes -> read_chunks(IStrm,Cs) ; Cs = []), !.

read_section(IStrm, S) :- read_chunks(IStrm, Cs), flatten(Cs,S).

open_input(FName,IStrm) :- open(FName, read, IStrm, [type(binary)]).
close_input(IStrm) :- close(IStrm).

% read in the list of image files (.PCX)
parse_filedir(Fdir,FDir). % TODO!
read_files_directory(IS, FDir) :-
  seek(IS,bof, 0x1c380, 0x1c380),
  read_section(IS,Entries),
  parse_filedir(Entries, FDir).

% parse book contents
parse_until(IStrm, Finish, []) :- stream_position(IStrm,Finish), !.
parse_until(IStrm, Finish, [B|Bs]) :-
  read_section(IStrem, B), !,
  parse_until(IStrm, Finish, Bs).

parse_book(IStrm, Start, Finish, Book) :-
  seek(IStrm, bof, Start, Start),
  parse_until(IStrm, Finish, Book). 

% conveniences...
fname(formats_collection,'~/win/Downloads/DDJFORM.HW4').
fname(algos_collection,'~/win/Downloads/ALGO.HW4').

book_span(file_formats, 0x4bb40, 0xe45f0).
book_span(graphics_formats, 0xe4bc0, 0x01b3a80).
book_span(windows_formats, 0x1b3e80, 0). % TODO!

main :-
  fname(formats_collection,Fname),
  open_input(Fname,IS),
  read_files_directory(IS,FDir),
  book_span(file_formats, Start, Finish),
  parse_book(IS, Start, Finish, _),
  close_input(IS).

% vim: filetype=prolog : sw=2 : ts=2 : sts=2 : expandtab :
