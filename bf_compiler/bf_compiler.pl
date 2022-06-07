:- initialization(main).

% define the bf language primitives
bf_cmd('>',right). bf_cmd('<',left).
bf_cmd('+',incr). bf_cmd('-',decr).
bf_cmd('.',putch). bf_cmd(',',getch).
bf_cmd('[',while). bf_cmd(']',wend).

% boilerplate for the C program...
print_frontmatter :- print('#include<stdio.h>\nstatic char array[30000];\n'),
  print('int main(int argc, char *argv[]) {\nchar *ptr = array;\n').
print_endmatter :- print('  return 0;\n}').

% utility to read all primitives from the program
read_chars(IS, CHS) :- get_char(IS, Code),
  (Code = end_of_file 
    -> CHS = [] 
    ; (bf_cmd(Code,Primitive) 
        -> CHS=[Primitive|Ps], read_chars(IS,Ps) 
        ; read_chars(IS,CHS) ) ).
file_contents(FName, Contents) :- open(FName, read, IS), read_chars(IS, Contents), close(IS).

% compiler is here

% optimization pass 1 -- collect runs of commands...
collectible(C) :- member(C,[right,left, incr, decr]).
opt_1(X,none,[],[X]).
opt_1(X,N,[],[Constructed]) :- Constructed =.. [X,N].
opt_1(X,none,[C|Cs], [X|Xs]) :- collectible(C) -> opt_1(C,1,Cs,Xs) ; opt_1(C,none,Cs,Xs).
opt_1(C,N,[C|Cs], Result) :- N1 is N + 1, opt_1(C,N1,Cs,Result).
opt_1(X,N,[C|Cs], [Constructed|Xs]) :- Constructed =.. [X,N],
  (collectible(C) -> opt_1(C,1,Cs,Xs) ; opt_1(C,none,Cs,Xs) ).

compile(Program, Compiled) :- opt_1(nop,none,Program,Compiled).

% format the code...
translate(right(N),F) :- format_to_atom(F,'  ptr += ~d;\n',[N]).
translate(left(N),F) :- format_to_atom(F,'  ptr -= ~d;\n',[N]).
translate(incr(N),F) :- format_to_atom(F,'  *ptr += ~d;\n',[N]).
translate(decr(N),F) :- format_to_atom(F,'  *ptr -= ~d;\n',[N]).
translate(putch,'  putchar(*ptr);\n'). translate(getch,'  *ptr = getchar();\n').
translate(while,'  while(*ptr) {\n').  translate(wend,'  }\n').
translate(nop,'').

format_code([]).
format_code([C|Cs]) :- translate(C,OStr), print(OStr), !, format_code(Cs).

% a `main` predicate to get things moving...
run_file(FName) :- print_frontmatter, file_contents(FName, Program), !,
  compile(Program,Code), format_code(Code), print_endmatter.

main :- argument_counter(2), argument_value(1,FName), run_file(FName).
main :- print('Usage: bf_compiler <code.bf>\n').

% vim: filetype=prolog
