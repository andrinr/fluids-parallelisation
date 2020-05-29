# Exercise Sheet 10

## HPC, Andrin Rehmann

### Exercise 1

The GPU speedup compared to CPU speedup only becomes relevant when the problem reached very high dimensions.

```bash
 memcopy and daxpy test of size 33554432
 -------
 timings
 -------
 axpy (omp) :  7.16865389840677381E-2 s
 axpy (gpu) :  4.414755804464221E-2 s
 copyin     :  3.99304553866386414E-8 s
 copyout    :  3.09664756059646606E-8 s
 TOTAL      :  4.41476289415732026E-2 s
```



### Exercise 2

When using the naive method: 

```bash
srun blur.openacc 25 100

dispersion 1D test of length n = 33554436 : 256MB
==== success ====
Host version took 33.1017 s (0.331017 s/step)
GPU version took 33.0553 s (0.330553 s/step)
```

When using the method with nocpoies: 

```bash
srun blur.openacc 25 100
dispersion 1D test of length n = 33554436 : 256MB
==== success ====
Host version took 33.1686 s (0.331686 s/step)
GPU version took 32.9125 s (0.329125 s/step)
dispersion 1D test of length n = 33554436 : 256MB
```

So probably I missed something...



### Exercise 3

The dot product is more prone to race condition since we have to basicially sum up all the results in the loop, meaning the opreation cannot be vectorized as easily as we did before.



