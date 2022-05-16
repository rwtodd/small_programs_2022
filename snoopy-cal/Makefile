.PHONY: clean
snoopy-cal: cal.c picdat.inc extdat.inc
	$(CC) -O3 -march=native -o $@ cal.c

clean:
	-rm snoopy-cal
