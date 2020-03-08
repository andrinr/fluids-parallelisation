CFLAGS=-Wall -O3 -ffast-math -mavx2 -fopenmp
LDFLAGS=-fopenmp

sum	: sum.o getTime.o

sum.o	: sum.c getTime.h

getTime.o:	getTime.c getTime.h

clean: 	rm -f sum sum.o getTime.o

	

