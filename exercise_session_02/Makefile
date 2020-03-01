
cpi_omp: cpi_omp.c
	cc -O3 -o cpi_omp -fopenmp cpi_omp.c 

cpi_mpi: cpi_mpi.c
	cc -O3 -o cpi_mpi cpi_mpi.c 

cpi_serial: cpi_serial.c
	cc -03 -o cpi_serial cpi_serial.c
 
a0ll: cpi_omp cpi_mpi cpi_serial

clean:
	rm -f cpi_omp cpi_mpi cpi_serial
