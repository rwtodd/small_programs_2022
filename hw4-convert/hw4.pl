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
parse_filedir(FDir,FDir). % TODO!
read_files_directory(IS, FDir) :-
  seek(IS,bof, 0x1c380, 0x1c380),
  read_section(IS,Entries),
  parse_filedir(Entries, FDir).

% parse book contents
parse_book(IStrm, _, _, Start, Finish) :-
  format('%X\n',[Finish]), % TODO
  seek(IStrm, bof, Start, Start),
  repeat,
    read_section(IStrm, Sect),
    seek(IStrm, current, 0, Location),
    length(Prefix, 16), append(Prefix,_,Sect), format('%X: ~p\n',[Location,Prefix]), % TODO!
    Location >= Finish.


% conveniences...
fname(formats_collection,'~/win/Downloads/DDJFORM.HW4').
fname(algos_collection,'~/win/Downloads/ALGO.HW4').

book_info(file_formats, 'ff_', 0x4bb40, 0xe4600).
book_info(graphics_formats, 'gf_', 0xe4bc0, 0x01b3a80).
book_info(windows_formats, 'wf_', 0x1b3e80, 0). % TODO!

run(Collection,Book) :-
  fname(Collection,Fname),
  open_input(Fname,IS),
  read_files_directory(IS,FDir),
  book_info(Book, Prefix, Start, Finish),
  parse_book(IS, Prefix, FDir, Start, Finish), !,
  close_input(IS).

% run the first book for now
main :- run(formats_collection, file_formats).

% vim: filetype=prolog : sw=2 : ts=2 : sts=2 : expandtab :
