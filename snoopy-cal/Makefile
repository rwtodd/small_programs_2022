.PHONY: clean
snoopy-cal: cal.c picdata.inc worddata.inc
	$(CC) -O3 -march=native -o $@ cal.c

clean:
	-rm snoopy-cal
