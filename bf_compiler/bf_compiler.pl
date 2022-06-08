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

% compiler is here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% to run a peephole optimization pass, we need to try the optimization everywhere in the
% code.  If it passes, it pushes the transform for the next parser.  If it fails, just
% pop whatever is next and move on...
peephole_pass(Pass,X) --> Pass, !, peephole_pass(Pass,X).
peephole_pass(Pass,[X|Xs]) --> [X], !, peephole_pass(Pass,Xs).
peephole_pass(_,[]) --> [].

% pass to gather consecutive moves and adds
opt_consec, [move(N3)] --> [move(N1)],[move(N2)], { N3 is N1+N2 }.
opt_consec, [add(N3)] --> [add(N1)],[add(N2)], { N3 is N1+N2 }.

% peephole optimize [-] to set(0).
opt_setZero, [set(0)] --> [while],[add(N)],[wend], { N < 0 }.

% peephole optimize set+add to one set.
opt_setAdd, [set(N3)] -->  [set(N1)],[add(N2)], { N3 is N1 + N2 }.

% peephole optimize add superfluous before set.
opt_addSet, [set(N)] --> [add(_),set(N)].

% peephole optimize [>++<-] and similar into an 
% offset add by a factor of the current cell.
opt_addOffset, [addMultipleAtOffs(N,A),set(0)] -->
  [while],[move(N)],[add(A)],[move(N2)],[add(-1)],[wend], { N2 is -N }.
opt_addOffset, [addMultipleAtOffs(N,A),set(0)] -->
  [while],[add(-1)],[move(N)],[add(A)],[move(N2)],[wend], { N2 is -N }.

run_phase(P,Code,Opt) :- phrase(peephole_pass(P,Opt),Code).

% now capture the structure of the code by nesting the loops...
tree_xform([while_loop(WL)|Xs]) --> [while], !, tree_xform(WL), tree_xform(Xs).
tree_xform([X|Xs]) --> [X], { X \= wend }, !, tree_xform(Xs).
tree_xform([]) --> [wend] | [].

code_to_tree(Code,Tree) :- phrase(tree_xform(Tree),Code).

% now eliminate an initial while loop, which will never run...
opt_initialWhile([while_loop(_)|Cs], Cs) :- !. 
opt_initialWhile(Cs, Cs).

% now turn a while loop that ends in a set(0) to an if_block...
whileToIf_xform(while_loop(Code), if_block(Code)) :- last(Code,set(0)).

tree_opt(XForm, [while_loop(Code)|Ts], [Opt|Opts]) :- tree_opt(XForm,Code,NewCode), 
  ( call(XForm,while_loop(NewCode),Opt) ; Opt=while_loop(NewCode) ), !, tree_opt(XForm,Ts,Opts).
tree_opt(XForm, [if_block(Code)|Ts], [Opt|Opts]) :- tree_opt(XForm,Code,NewCode), 
  ( call(XForm,if_block(NewCode),Opt) ; Opt=if_block(NewCode) ), !, tree_opt(XForm,Ts,Opts).
tree_opt(XForm, [T|Ts], [Opt|Opts]) :- (call(XForm,T,Opt) ; Opt=T), !, tree_opt(XForm,Ts,Opts).
tree_opt(_,[],[]).

compile --> run_phase(opt_consec), run_phase(opt_setZero), 
   run_phase(opt_setAdd), run_phase(opt_addSet), run_phase(opt_addOffset), 
   code_to_tree, opt_initialWhile, tree_opt(whileToIf_xform).

% format the output primitive codes...
translate(addMultipleAtOffs(N,A),F) :- format_to_atom(F,'*(ptr + ~d) += (~d * *ptr);\n',[N,A]).
translate(move(N),F) :- format_to_atom(F,'ptr += ~d;\n',[N]).
translate(add(N),F) :- format_to_atom(F,'*ptr += ~d;\n',[N]).
translate(set(N), F) :- format_to_atom(F,'*ptr = ~d;\n',[N]).
translate(putch,'putchar(*ptr);\n'). translate(getch,'*ptr = getchar();\n').
translate(while,'ERROR!!!! WHILE !!!!! \n').  translate(wend,'ERROR!!!! WEND !!!!!\n').
translate(nop,'ERROR!!!! NOP !!!!').

% format_code(indent_lvl, code)
format_code([]).
format_code([while_loop(WL)|Cs]) :- !, print('while(*ptr) {\n'), format_code(WL), print('}\n'), format_code(Cs). % TODO indent
format_code([if_block(IB)|Cs]) :- !, print('if(*ptr) {\n'), format_code(IB), print('}\n'), format_code(Cs). % TODO indent
format_code([C|Cs]) :- translate(C,OStr), !, print(OStr), !, format_code(Cs).

% a `main` predicate to get things moving...
run_file(FName) :- file_contents(FName, Code), !,
  compile(Code,Optimized), !, 
  print_frontmatter, format_code(Optimized), print_endmatter.

main :- argument_counter(2), argument_value(1,FName), !, run_file(FName).
main :- print('Usage: bf_compiler <code.bf>\n').

% vim: filetype=prolog
