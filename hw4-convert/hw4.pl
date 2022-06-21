% convert hyperReader 4 files to html
:- initialization(main).

% parsing helpers...
eos([],[]). % detect end of stream

% many like regex '*'
many(P,[X|Xs]) --> call(P, X), !, many(P,Xs).
many(_,[]) --> [].

% many_plus like regex '+'
many_plus(P,[X|Xs]) --> call(P,X), !, many(P,Xs).

skip_rest --> [_], !, skip_rest.
skip_rest --> [].

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

% Book output code ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% state is state(FileDir, OutFile, Bold, Italic, Underline, Red, Superscript)
state_init(OFName, FileDir, state(FileDir, OF, off, off, off, off, off)) :- 
  open(OFName, write, OF).

% change State, setting place N to V, and returning it as State1
change_state(State,N,V,State1) :- copy_term(State,State1), setarg(N,State1,V), !.

% the attributes (bold/italic/etc) will be either 'on' or 'off'
toggle(on,off).
toggle(off,on).
% toggle a state, returning the changed State1, and the new value V1
state_toggle(State,N,State1,V1) :- arg(N,State,V), toggle(V,V1), change_state(State, N, V1, State1).

% getters/setters...
state_fdir(State,FD) :- arg(1,State,FD).
state_ofile(State,F) :- arg(2,State,F).
state_isbold(State) :- arg(3,State,on).
state_isitalic(State) :- arg(4,State,on).
state_isunderline(State) :- arg(5,State,on).
state_isred(State) :- arg(6,State,on).
state_issuperscript(State) :- arg(7,State,on).

state_toggle_bold(State,State1,V)      :- state_toggle(State,3,State1,V).
state_toggle_italic(State,State1,V)    :- state_toggle(State,4,State1,V).
state_toggle_underline(State,State1,V) :- state_toggle(State,5,State1,V).
state_toggle_red(State,State1,on)      :- change_state(State,6,on,State1).
state_toggle_black(State, State1, off) :- change_state(State,6,off,State1).
state_toggle_superscript(State,State1,V) :- state_toggle(State,7,State1,V).
state_close(State) :- state_ofile(State,OF), close(OF).

% format a single list of inner text
format_one_code(OF, toggle_bold, State, State1) :-
  !,
  state_toggle_bold(State, State1, B),
  (B = on 
    -> print(OF, '\\textbf{')
    ;  print(OF, '}') ).
format_one_code(OF, toggle_italic, State, State1) :-
  !,
  state_toggle_italic(State, State1, B),
  (B = on 
    -> print(OF, '\\textit{')
    ;  print(OF, '}') ).
format_one_code(OF, toggle_superscript, State, State1) :-
  !,
  state_toggle_superscript(State, State1, B),
  (B = on 
    -> print(OF, '$^{')
    ;  print(OF, '}$') ).
format_one_code(OF, toggle_underline, State, State1) :-
  !,
  state_toggle_underline(State, State1, B),
  (B = on 
    -> print(OF, '\\underline{')
    ;  print(OF, '}') ).
format_one_code(OF, toggle_red, State, State1) :-
  !,
  (state_isred(State)
    -> State1 = State
    ; state_toggle_red(State, State1, _),
      print(OF, '\\textcolor{redtxt}{')).
format_one_code(OF, toggle_black, State, State1) :-
  !,
  (\+ state_isred(State)
    -> State1 = State
    ; state_toggle_black(State, State1, _),
      print(OF, '}')).
format_one_code(OF, image(NL,NH), State, State) :-
  !,
  Num is NH*256+NL,
  print(OF,'\n\n\\image{'),
  state_fdir(State,FDir),
  nth(Num,FDir,FName),
  print(OF,FName),
  print(OF, '}\n\n').

format_one_code(OF, word(XS), State, State) :-
  !,
  atom_codes(A,XS),
  print(OF,A).

format_one_code(OF, X, State, State) :- put_code(OF,X).

undo_all_states(OF,State,State1) :- 
  (state_isbold(State) ->  format_one_code(OF, toggle_bold,State,StateB)
                       ;   StateB = State),
  (state_isitalic(State) ->  format_one_code(OF, toggle_italic,StateB,StateI)
                       ;   StateI = StateB),
  (state_isunderline(State) ->  format_one_code(OF, toggle_underline,StateI,StateU)
                       ;   StateU = StateI),
  (state_isred(State) ->  format_one_code(OF, toggle_black,StateU,StateR)
                       ;   StateR = StateU),
  (state_issuperscript(State) ->  format_one_code(OF, toggle_superscript,StateR,State1)
                       ;   State1 = StateR).

format_inner_text(OF, [], State, State1) :-
  undo_all_states(OF,State,State1).
format_inner_text(OF, [C|Cs], State, State1) :-
  format_one_code(OF,C,State,StateX), !,
  format_inner_text(OF, Cs, StateX, State1).

% format a series of inner text's, like you get in tables
format_inner_text_list([],_,State,State).
format_inner_text_list([IT|ITs],Prefix,State,State1) :-
  state_ofile(State,OF),
  (Prefix = '' ; print(OF, Prefix)),
  format_inner_text(OF,IT,State,StateX),
  print(OF,'\n'),
  format_inner_text_list(ITs,Prefix,StateX,State1).
  
format_one_frag(frag(chapter,P),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n\\chapter{'),
  format_inner_text(OF, P,State,State1), 
  print(OF,'}\n').

format_one_frag(frag(heading,P),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n\\section{'),
  format_inner_text(OF, P,State,State1), 
  print(OF,'}\n').

format_one_frag(frag(subheading,P),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n\\subsection{'),
  format_inner_text(OF, P,State,State1), 
  print(OF,'}\n').

%format_one_frag(frag(image,I),State,State) :-
%  state_ofile(State,OF),
%  I=[0x11,0x17,0x01,0x17,ImLow,ImHigh|_],
%  Img is ImHigh*256 + ImLow,
%  print(OF,'\n\n\\image{'),
%  state_fdir(State,FDir),
%  nth(Img,FDir,FName),
%  print(OF,FName),
%  print(OF,'}\n').

format_one_frag(table(X),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n% table\n\\begin{verbatim}'),
  format_inner_text_list(X,'',State,State1),
  print(OF,'\n\\end{verbatim}\n\n').

format_one_frag(code(X),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n% code\n\\begin{verbatim}'),
  format_inner_text_list(X,'',State,State1),
  print(OF,'\n\\end{verbatim}\n\n').

format_one_frag(listing(X),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n% listing\n\\begin{verbatim}'),
  format_inner_text_list(X,'',State,State1),
  print(OF,'\n\\end{verbatim}\n\n').

format_one_frag(enum_list(X),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n\\begin{itemize}'),
  format_inner_text_list(X,'\\item ',State,State1),
  print(OF,'\n\\end{itemize}\n\n').

format_one_frag(cmark_list(X),State,State1) :-
  state_ofile(State,OF),
  print(OF,'\n\n\\begin{enumerate}'),
  format_inner_text_list(X,'\\item ',State,State1),
  print(OF,'\n\\end{enumerate}\n\n').

format_one_frag(frag(_,P),State,State1) :-
  state_ofile(State,OF),
  format_inner_text(OF, P,State,State1),
  print(OF,'\n\n').

format_output(nothing, State, State).
format_output([], State, State).
format_output([X|Xs], State0, State1) :-
  print(X),nl,nl, % TODO testing code...
  format_one_frag(X,State0,StateX), !,
  format_output(Xs,StateX,State1).

% Book parsing code ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The inner text has codes that need to be rendered
not_a_12(X) --> [X], { X \= 0x12 }.
hex_zero(0) --> [0x00].

inner_text                       --> [0x09], skip(6), [0x09].
inner_text, [image(NL,NH)]       --> [0x11,0x17,0x01,0x17,0x00], !, take(2, [NL,NH]), skip_rest, !.
inner_text, [toggle_bold]        --> [0x05,0x01,0x05].
inner_text, [toggle_italic]      --> [0x05,0x02,0x05].
inner_text, [toggle_underline]   --> [0x05,0x04,0x05].
inner_text, [toggle_superscript] --> [0x05,0x10,0x05].
inner_text, [word([0x5c,0x25])]  --> [0x25].  % \%
inner_text, [word([0x5c,0x24])]  --> [0x24].  % \$
inner_text, [word([92,116,101,120,116,98,97,99,107,115,108,97,115,104,123,125])]  --> [0x5c].  % \textbackslash
inner_text, [124]                --> [0x07,0x07,0x0a,0x00,0x07,0xab].
inner_text, [43]                 --> [0x07,0x07,0x0a,0x00,0x07,0xf9].
inner_text, [toggle_red]         --> [0x07], many(hex_zero,_), [0x06, 0x0a, 0x00, 0x07, 0x0b, 0xfc, 0x0b].
inner_text, [toggle_black]       --> [0x07], many(hex_zero,_), [0x07, 0x0c].
inner_text                       --> [0x07], many(hex_zero,_), [0x07].
inner_text, [word(XS)]           --> [0x01], skip(2), [0x01], many_plus(not_a_12,XS), [0x12]. 
inner_text, [0x20,0x20]          --> [0x10].

parse_inner_text(X) --> inner_text, !, parse_inner_text(X).
parse_inner_text([X|Xs]) --> [X], !, parse_inner_text(Xs).
parse_inner_text([]) --> [].

% fragments have many types
type_codes(0x06, chapter).
type_codes(0x09, heading).
type_codes(0x0a, caption).
type_codes(0x0b, table_text).
type_codes(0x0c, table_header).
type_codes(0x10, subheading).
%type_codes(0x11, image).  % maybe?
%type_codes(0x14, image).
type_codes(0x15, code).
type_codes(0x17, table_text).
type_codes(0x1c, note).
type_codes(0x1e, listing_title).
type_codes(0x1d, bullet_point).
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

bullet(B) --> [frag(bullet_point,B)].
checkmark(C) --> [frag(checkmark,C)].
table_text(C) --> [frag(table_text,C)].
listing_text(L) --> [frag(listing,L)].
code_text(C) --> [frag(code,C)].

% we need to collect lists into a bigger structure, so we'll post-process the fragments by type
clean_frags_helper(enum_list(Bs)) --> many_plus(bullet,Bs). 
clean_frags_helper(cmark_list(Cs)) --> many_plus(checkmark,Cs).
clean_frags_helper(table(Ts)) --> many_plus(table_text,Ts).
clean_frags_helper(listing(Ls)) --> many_plus(listing_text,Ls).
clean_frags_helper(code(Cs)) --> many_plus(code_text,Cs).
clean_frags_helper(X) --> [X].

clean_frags([X|Xs]) --> clean_frags_helper(X), !, clean_frags(Xs).
clean_frags([]) --> [].

parse_one_fragment(frag(Type, Content)) --> [LenLow,LenHi,TypeCode], { Len is LenHi * 256 + LenLow - 1}, 
  { Len >= 0 }, { type_codes(TypeCode, Type) }, take(Len,RawContent),
  { phrase(parse_inner_text(Content), RawContent) }.

parse_wanted(Parsed) --> many_plus(parse_one_fragment, Frags), { phrase(clean_frags(Parsed),Frags) }.

% determine if it's a section we want to output, and parse it if it's wanted
parse_section(Parsed) --> [0x00, 0x03], skip(3), [0x00, 0x01, Type],
   { Type \= 0x38 }, skip(6), [Sz], { member(Sz,[2,3]) }, [0x03], 
   skip(29), ([0xff] | [_,0xff]), !, parse_wanted(Parsed).
parse_section(nothing) --> [].

% parse book contents
parse_book_helper(IStrm, Finish, InState) :-
    read_section(IStrm, Sect),
    phrase(parse_section(Parsed),Sect, Rest),
    ( Parsed = nothing ; sum_list(Rest,0) ), 
    format_output(Parsed, InState, OutState),
    seek(IStrm, current, 0, Location),
    (Location < Finish 
      -> parse_book_helper(IStrm, Finish, OutState)
      ;  state_close(OutState) ).
   
% parse_book(Stream, Output_prefix, FileDir, StartLoc, FinishLoc)
parse_book(IStrm, Prefix, FDir, Start, Finish) :-
  state_init(Prefix, FDir, State0),
  seek(IStrm, bof, Start, Start),
  parse_book_helper(IStrm, Finish, State0).

% Setup and main ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% conveniences...
% hw4_info(name, file, directory_location).
fname(formats_collection,'~/win/Downloads/DDJFORM.HW4', fdir(0x1c340,56)).
fname(algos_collection,'~/win/Downloads/ALGO.HW4', fdir(0x38680, 36)).
% TESTING fname(algos_collection,'~/win/Downloads/ALGO.HW4', fdir(0x45a00, 0)).

% book_info(name, output_name, start_location, end_location).
book_info(file_formats, 'ff_hw4.tex', 0x4bb40, 0xe4600).
% TEST book_info(file_formats, 'ff_hw4.tex', 0xc4900, 0xe2e40).
book_info(graphics_formats, 'gf_hw4.tex', 0xe4bc0, 0x01b3a80).
% TEST book_info(graphics_formats, 'gf_hw4.tex', 949056, 0x01b3a80).
book_info(windows_formats, 'wf_hw4.tex', 0x1b3e80, 0). % TODO!

run(Collection,Book) :-
  fname(Collection,Fname, FDirLoc),
  open_input(Fname,IS),
  read_files_directory(IS,FDirLoc, FDir),
  book_info(Book, OFName, Start, Finish),
  parse_book(IS, OFName, FDir, Start, Finish), !,
  close_input(IS).

just_get_fdir(Collection,FDir) :-   % for testing
  fname(Collection,Fname, FDirLoc),
  open_input(Fname,IS),
  read_files_directory(IS,FDirLoc, FDir),
  close_input(IS).

% run the first book for now
main :- run(formats_collection, graphics_formats).

% vim: filetype=prolog : sw=2 : ts=2 : sts=2 : expandtab :
