# HP EX3

## Andrin Rehmann



### Execution times values:

```
Process rank: 8
Time passed: 0.158903.
Process rank: 9
Time passed: 0.158902.
Process rank: 11
Time passed: 0.158873.
Process rank: 12
Time passed: 0.158957.
Process rank: 15
Time passed: 0.158928.
Process rank: 16
Time passed: 0.158840.
Process rank: 18
Time passed: 0.158951.
Process rank: 19
Time passed: 0.158940.
Process rank: 20
Time passed: 0.158834.
Process rank: 21
Time passed: 0.158904.
Process rank: 25
Time passed: 0.158936.
Process rank: 26
Time passed: 0.158893.
Process rank: 27
Time passed: 0.158831.
Process rank: 30
Time passed: 0.159022.
Process rank: 34
Time passed: 0.158885.
Process rank: 0
```

The differences in execution times are very small but explainable thru a degree of randomness in the CPU. 



### Different execution times for different levels of optimization: 



Not sure how to make different optimizations.  Probably an error in the makefile:

```

sum2    : sum2.o getTime.o
        cc -o sum sum2.o getTime.o

sum3    : sum3.o getTime.o
        cc -o sum sum3.o getTime.o

sum0.o  : sum.c getTime.h
        cc -O0 -ffast-math -c -o sum0.o sum.c

sum1.o  : sum.c getTime.h
        cc -O1 -ffast-math -c -o sum1.o sum.c

sum2.o  : sum.c getTime.h
        cc -O2 -ffast-math -c -o sum2.o sum.c

sum3.o  : sum.c getTime.h
        cc -O3 -ffast-math -c -o sum3.o sum.c

getTime.o:      getTime.c getTime.h

clean:  rm -f sum sum.o getTime.o
```



### Open MP version of sum.c

The file sum.c is in the repo. 

Inserted the line right before the for loop line.

Job script for open mp version:

```
#!/bin/bash -l
#SBATCH --job-name="CPI MPI"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=andrinrehman@gmail.com
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=nomultithread
#SBATCH --account=uzh8

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
```

And the make file:

```
CFLAGS=-Wall -O3 -ffast-math -mavx2 -fopenmp
LDFLAGS=-fopenmp

sum     : sum.o getTime.o

sum.o   : sum.c getTime.h

getTime.o:      getTime.c getTime.h

clean:  rm -f sum sum.o getTime.o
```



### Superlinear Speedup

Because each CPU has built in Cache, thus when increasing the number of processors the Cache capacity increases, thus the RAM doesn't have to be accessed and overhead is decreased. 