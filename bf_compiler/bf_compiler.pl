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

% the base compiler is here
translate(right,'  ++ptr;\n').         translate(left,'  --ptr;\n').
translate(incr,'  ++*ptr;\n').         translate(decr,'  --*ptr;\n'). 
translate(putch,'  putchar(*ptr);\n'). translate(getch,'  *ptr = getchar();\n').
translate(while,'  while(*ptr) {\n').  translate(wend,'  }\n').

compile([]).
compile([Prim|Ps]) :- translate(Prim,Code), print(Code), !, compile(Ps).

% a `main` predicate to get things moving...
main(FName) :- print_frontmatter, file_contents(FName, Program), !, compile(Program), print_endmatter.

% vim: filetype=prolog
