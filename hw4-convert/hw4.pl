% convert hyperReader 4 files to html

% parsing helpers...
eos([],[]). % detect end of stream

many(P,[X|Xs]) --> call(P, X), !, many(P,Xs).
many(_,[]) --> [].

skip(0) --> [].
skip(N) --> { N  > 0 }, [_], { N1 is N - 1 }, skip(N1).

take(0,[]) --> !, [].
take(N,[T|Ts]) --> [T], { N1 is N - 1 }, take(N1,Ts).

% read 64 bytes at a time, and keep adding until the last four bytes are not 00 00 00 00
read_64(IStrm, Bs, More) :- length(Bs, 60), maplist(get_byte(IStrm), Bs), !, length(LastFour,4),
  maplist(get_byte(IStrm), LastFour), !, (LastFour = [0,0,0,0] -> More = yes ; More = no).

read_chunks(IStrm, [C|Cs]) :- read_64(IStrm, C, More), !,
  (More = yes -> read_chunks(IStrm,Cs) ; Cs = []), !.

read_section(IStrm, S) :- read_chunks(IStrm, Cs), flatten(Cs,S).

open_input(FName,IStrm) :- open(FName, read, IStrm, [type(binary)]).
close_input(IStrm) :- close(IStrm).

% read in the list of image files (.PCX) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% a dos filename ends in a 3-char extension in the HW4 file
dos_fname([0x2e,X,Y,Z]) --> [0x2e,X,Y,Z].  % .EXT
dos_fname([X|Xs]) --> [X], { X \= 0x2e }, { X \= 0x00 }, !, dos_fname(Xs).

% convert the many files into atoms
parse_filedir(Fs) --> many(dos_fname,Lists), !, { maplist(atom_codes,Fs, Lists) }.

% read all the entries in the files list, and parse them out by 3-char extensions
% into atoms
read_files_directory(IS, fdir(Loc,Skip), FDir) :-
  seek(IS, bof, Loc, Loc),
  read_section(IS,Entries),
  length(Skipped,Skip),
  append(Skipped,ToParse,Entries),
  phrase(parse_filedir(FDir), ToParse, Rest),
  (sum_list(Rest,0) ; Rest = [67]). % make sure the rest was all zeros or a single 'C'...
                                    % since that's what my files have

% Book parsing code ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
type_codes(0x06, chapter).
type_codes(0x09, heading).
type_codes(0x0a, caption).
type_codes(0x0b, table_text).
type_codes(0x0c, table_header).
type_codes(0x10, subheading).
type_codes(0x11, image).  % maybe?
type_codes(0x14, image).
type_codes(0x15, code).
type_codes(0x1c, note).
type_codes(0x1e, listing_title).
type_codes(0x1f, listing).
type_codes(0x2d, book_part).
type_codes(0x2e, plain). % body text
type_codes(0x2f, bullet_point). 
type_codes(0x30, checkmark).
type_codes(0x31, tip).
type_codes(0x32, warning).
type_codes(0x33, code). % "disk"
type_codes(0x34, number_list). % inside, 0x10 means "tab" kinda
type_codes(_, plain).

parse_one_fragment(frag(Type, Content)) --> [LenLow,LenHi,TypeCode], { Len is LenHi * 256 + LenLow - 1}, 
  { Len >= 0 }, { type_codes(TypeCode, Type)} , take(Len,Content).

parse_wanted(Frags) --> many(parse_one_fragment, Frags).

% determine if it's a section we want to output, and parse it if it's wanted
parse_section(Parsed) --> [0x00, 0x03], skip(2), [0x00, 0x00, 0x01, Type],
   { Type \= 38 }, skip(6), [Sz], { member(Sz,[2,3]) }, [0x03], 
   { ToSkip is 27 + Sz }, skip(ToSkip), [0xff], !, parse_wanted(Parsed).
parse_section(nothing) --> [].

% parse book contents
parse_book(IStrm, _, _, Start, Finish) :-
  seek(IStrm, bof, Start, Start),
  repeat,
    read_section(IStrm, Sect),
    phrase(parse_section(Parsed),Sect, Rest),
    ( Parsed = nothing ; sum_list(Rest,0) ),
    print(Parsed), nl,
    seek(IStrm, current, 0, Location),
    Location >= Finish.

% Setup and main ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% conveniences...
% hw4_info(name, file, directory_location).
fname(formats_collection,'~/win/Downloads/DDJFORM.HW4', fdir(0x1c340,56)).
fname(algos_collection,'~/win/Downloads/ALGO.HW4', fdir(0x38680, 36)).
% TESTING fname(algos_collection,'~/win/Downloads/ALGO.HW4', fdir(0x45a00, 0)).

% book_info(name, output_prefix, start_location, end_location).
book_info(file_formats, 'ff_', 0x4bb40, 0xe4600).
book_info(graphics_formats, 'gf_', 0xe4bc0, 0x01b3a80).
book_info(windows_formats, 'wf_', 0x1b3e80, 0). % TODO!

run(Collection,Book) :-
  fname(Collection,Fname, FDirLoc),
  open_input(Fname,IS),
  read_files_directory(IS,FDirLoc, FDir),
  book_info(Book, Prefix, Start, Finish),
  parse_book(IS, Prefix, FDir, Start, Finish), !,
  close_input(IS).

just_get_fdir(Collection,FDir) :-   % for testing
  fname(Collection,Fname, FDirLoc),
  open_input(Fname,IS),
  read_files_directory(IS,FDirLoc, FDir),
  close_input(IS).

% run the first book for now
main :- run(formats_collection, file_formats).

% vim: filetype=prolog : sw=2 : ts=2 : sts=2 : expandtab :
