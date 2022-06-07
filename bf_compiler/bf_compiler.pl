:- initialization(main).

% define the bf language primitives
bf_cmd('>',move(1)). bf_cmd('<',move(-1)).
bf_cmd('+',add(1)). bf_cmd('-',add(-1)).
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

% optimization pass 1 -- collect runs of add() and move() cmds
% opt_1(Codes,Optimized)
opt_1([],[]).
opt_1([move(N1),move(N2)|Cs],Opts) :- N3 is N1+N2, opt_1([move(N3)|Cs],Opts).
opt_1([add(N1),add(N2)|Cs],Opts) :- N3 is N1+N2, opt_1([add(N3)|Cs],Opts).
opt_1([C|Cs],[C|Opts]) :- opt_1(Cs,Opts).

% optimization pass 2 -- [-] == zero the current cell.
% opt_2(Codes,Optimized)
opt_2([],[]).
opt_2([while,add(N),wend|Cs],[set(0)|Xs]) :- N < 0, opt_2(Cs,Xs).
opt_2([X|Cs],[X|Xs]) :- opt_2(Cs,Xs).

% optimization pass 3 -- set(N)add(N2) == set(N+N2)
% opt_3(Codes,Optimized)
opt_3([],[]).
opt_3([set(N),add(N2)|Cs],[set(Tot)|Xs]) :- Tot is N+N2, opt_3(Cs,Xs).
opt_3([X|Cs],[X|Xs]) :- opt_3(Cs,Xs).

% optimization pass 4 -- while { move(N) add(A) move(-N) add(-1)  } wend
%    ==   add( ptr * A ) to loc N...
opt_4([],[]).
opt_4([while,move(N),add(A),move(N2),add(-1),wend|Cs],[addMultipleAtOffs(N,A),set(0)|Opts]) :-
  N2 is -N, !, opt_4(Cs,Opts).
opt_4([while,add(-1),move(N),add(A),move(N2),wend|Cs],[addMultipleAtOffs(N,A),set(0)|Opts]) :-
  N2 is -N, !, opt_4(Cs,Opts).
opt_4([X|Cs],[X|Xs]) :- opt_4(Cs,Xs).

compile(Program, Compiled) :- opt_1(Program,Compiled1),
  opt_2(Compiled1,Compiled2),
  opt_3(Compiled2,Compiled3),
  opt_4(Compiled3,Compiled4),
  Compiled=Compiled4.

% format the code...
translate(addMultipleAtOffs(N,A),F) :- format_to_atom(F,'  *(ptr + ~d) += (~d * *ptr);\n',[N,A]).
translate(move(N),F) :- format_to_atom(F,'  ptr += ~d;\n',[N]).
translate(add(N),F) :- format_to_atom(F,'  *ptr += ~d;\n',[N]).
translate(set(N), F) :- format_to_atom(F,'  *ptr = ~d;\n',[N]).
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
