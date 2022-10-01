.PHONY: clean

DEBUG?=0
ifeq ($(DEBUG),1)
	CFLAGS=-c -Wall -g -DJPEG2PDF_DEBUG=1
else
	CFLAGS=-c -Wall -O3 -march=native
endif

all: jpgpdf

# build
jpgpdf: jpgpdf.o main.o jpgpdf.h
	$(CC) jpgpdf.o main.o -o jpgpdf

jpgpdf.o: jpgpdf.c jpgpdf.h
	$(CC) $(CFLAGS) jpgpdf.c

main.o: main.c
	$(CC) $(CFLAGS) main.c

# cleanup
clean:
	rm -f *.o jpgpdf
