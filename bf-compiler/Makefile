bf_compiler: bf_compiler.pl
	gplc --no-top-level -C -O2 --c-compiler $(CC) bf_compiler.pl

.PHONY: examples clean
examples: cell_width rot13 hello_world fibo
clean:
	-rm cell_width rot13 hello_world fibo bf_compiler

cell_width: cell_width.bf bf_compiler
	./bf_compiler cell_width.bf > cell_width.c
	$(CC) -O2 -o $@ cell_width.c

rot13: rot13.bf bf_compiler
	./bf_compiler rot13.bf > rot13.c
	$(CC) -O2 -o $@ rot13.c


hello_world: hello_world.bf bf_compiler
	./bf_compiler hello_world.bf > hello_world.c
	$(CC) -O2 -o $@ hello_world.c

fibo: fibo.bf bf_compiler
	./bf_compiler fibo.bf > fibo.c
	$(CC) -O2 -o $@ fibo.c

