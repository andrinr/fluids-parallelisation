
sum0	: sum0.o getTime.o
	gcc -o sum sum0.o getTime.o

sum1	: sum1.o getTime.o
	gcc -o sum sum1.o getTime.o

sum2	: sum2.o getTime.o
	gcc -o sum sum2.o getTime.o

sum3	: sum3.o getTime.o
	gcc -o sum sum3.o getTime.o

sum.o	: sum.c getTime.h

getTime.o:	getTime.c getTime.h

clean: 	rm -f sum sum.o getTime.o

