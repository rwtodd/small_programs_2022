:- initialization(main).

% define the bf language primitives
bf_cmd('>',move(1)). bf_cmd('<',move(-1)).
bf_cmd('+',add(1)). bf_cmd('-',add(-1)).
bf_cmd('.',putch). bf_cmd(',',getch).
bf_cmd('[',while). bf_cmd(']',wend).

% boilerplate for the C program...
print_frontmatter :- print('#include<stdio.h>\nstatic char array[30000];\n'),
  print('int main(int argc, char *argv[]) {\n  char *ptr = array;\n').
print_endmatter :- print('  return 0;\n}').

% file_contents reads all primitives from the program, read_chars_ is a helper DCG.
read_chars_(IS) --> { get_char(IS,Code) },
  ( {bf_cmd(Code,Prim) } ->  [Prim] ; [] ),
  ( {Code = end_of_file} ; read_chars_(IS) ).

file_contents(FName, Primitives) :- open(FName, read, IS), phrase(read_chars_(IS),Primitives), close(IS).

% compiler starts here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% to run a peephole optimization pass, we need to try the optimization everywhere in the
% code.  If it passes, it pushes the transform for the next parser.  If it fails, just
% pop whatever is next and move on...
peephole_pass(Pass,X) --> Pass, !, peephole_pass(Pass,X).
peephole_pass(Pass,[X|Xs]) --> [X], !, peephole_pass(Pass,Xs).
peephole_pass(_,[]) --> [].

% pass to gather consecutive moves and adds
opt_consec, [move(N3)] --> [move(N1),move(N2)], { N3 is N1+N2 }.
opt_consec, [add(N3)] --> [add(N1),add(N2)], { N3 is N1+N2 }.

% peephole optimize [-] to set(0).
opt_setZero, [set(0)] --> [while,add(N),wend], { N < 0 }.

% peephole optimize set+add to one set.
opt_setAdd, [set(N3)] -->  [set(N1),add(N2)], { N3 is N1 + N2 }.

% peephole optimize away superfluous add before set.
opt_addSet, [set(N)] --> [add(_),set(N)].

% peephole optimize [>++<-] and similar into an 
% offset add by a factor of the current cell.
opt_addOffset, [addMultipleAtOffs(N,A),set(0)] -->
  [while,move(N),add(A),move(N2),add(-1),wend], { N2 is -N }.
opt_addOffset, [addMultipleAtOffs(N,A),set(0)] -->
  [while,add(-1),move(N),add(A),move(N2),wend], { N2 is -N }.

% it easier to ensure correctness by running each peephole phase
% independently, rather that trying to save execution time interleaving them.
run_phase(P,Code,Opt) :- phrase(peephole_pass(P,Opt),Code).

% code_to_tree captures the structure of the code by nesting the loops... tree_xform is a helper.
tree_xform([while_loop(WL)|Xs]) --> [while], !, tree_xform(WL), tree_xform(Xs).
tree_xform([X|Xs]) --> [X], { X \= wend }, !, tree_xform(Xs).
tree_xform([]) --> [wend] | [].

code_to_tree(Code,Tree) :- phrase(tree_xform(Tree),Code).

% Eliminate an initial while loop, which will never run...
opt_initialWhile([while_loop(_)|Cs], Cs) :- !. 
opt_initialWhile(Cs, Cs).

% tree_opts run across all the terms in the code tree (as built by code_to_tree).
tree_opt(XForm, [while_loop(Code)|Ts], [Opt|Opts]) :- tree_opt(XForm,Code,NewCode), 
  ( call(XForm,while_loop(NewCode),Opt) ; Opt=while_loop(NewCode) ), !, tree_opt(XForm,Ts,Opts).
tree_opt(XForm, [if_block(Code)|Ts], [Opt|Opts]) :- tree_opt(XForm,Code,NewCode), 
  ( call(XForm,if_block(NewCode),Opt) ; Opt=if_block(NewCode) ), !, tree_opt(XForm,Ts,Opts).
tree_opt(XForm, [T|Ts], [Opt|Opts]) :- (call(XForm,T,Opt) ; Opt=T), !, tree_opt(XForm,Ts,Opts).
tree_opt(_,[],[]).

% Our first tree_opt will turn a while loop that ends in a set(0) to an if_block...
whileToIf_xform(while_loop(Code), if_block(Code)) :- last(Code,set(0)).

% compile/2 threads together all of our optimization passes
compile --> run_phase(opt_consec), run_phase(opt_setZero), 
   run_phase(opt_setAdd), run_phase(opt_addSet), run_phase(opt_addOffset), 
   code_to_tree, opt_initialWhile, tree_opt(whileToIf_xform).

% END of compiler... now output C code...
%
% format the output primitive codes...
translate(addMultipleAtOffs(N,A),F) :- format_to_atom(F,'*(ptr + ~d) += (~d * *ptr);\n',[N,A]).
translate(move(N),F) :- format_to_atom(F,'ptr += ~d;\n',[N]).
translate(add(N),F) :- format_to_atom(F,'*ptr += ~d;\n',[N]).
translate(set(N), F) :- format_to_atom(F,'*ptr = ~d;\n',[N]).
translate(putch,'putchar(*ptr);\n'). translate(getch,'*ptr = getchar();\n').

% Whitespace-handling for our pretty-print
create_ws(WS,WS1) :- format_to_atom(WS1,'  ~a',[WS]).
prprint(WS,TXT) :- print(WS), print(TXT).

% format_code(indent_whitespace, code)
format_code(_,[]).
format_code(WS, [while_loop(WL)|Cs]) :- !, prprint(WS,'while(*ptr) {\n'),
  create_ws(WS,WS1), format_code(WS1,WL), prprint(WS,'}\n'), format_code(WS,Cs). 
format_code(WS,[if_block(IB)|Cs]) :- !, prprint(WS,'if(*ptr) {\n'),
  create_ws(WS,WS1), format_code(WS1,IB), prprint(WS,'}\n'), format_code(WS,Cs).
format_code(WS,[C|Cs]) :- translate(C,OStr), !, prprint(WS,OStr), format_code(WS,Cs).

% a `main` predicate to get things moving...
run_file(FName) :- file_contents(FName, Code), !,
  compile(Code,Optimized), !, 
  print_frontmatter, format_code('  ',Optimized), print_endmatter.

main :- argument_counter(2), argument_value(1,FName), !, run_file(FName).
main :- print('Usage: bf_compiler <code.bf>\n').

% vim: filetype=prolog
