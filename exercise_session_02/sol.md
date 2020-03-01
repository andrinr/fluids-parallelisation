# HP Exercise Sheet 2

## Andrin Rehmann

### Exercise 2

- The `cc` flag invokes the c compiler with the current programming environment.

- The -O flag defines the level of optimization, where 03 is defined as:

      -O2 Moderate level of optimization which enables most optimizations.
      -O3 Like -O2, except that it enables optimizations that take longer to perform or that may gener-ate larger code (in an attempt to make the program run faster).

- The level O0 is defined as:

  ```
  -O0  Means  "no  optimization": this level compiles the fastest and generates the most debuggable code.
  ```

- The current programming environment is: PrgEnv-cray/6.0.5(default)

### Exercise 3

- `sinfo -p debug` returns: 

```
PARTITION AVAIL JOB_SIZE  TIMELIMIT   CPUS  S:C:T   NODES STATE      NODELIST
debug     up    1-4           30:00     24 1:12:2       2 allocated  nid0[4276-4277]
debug     up    1-4           30:00    24+ 1+:12+      14 idle       nid0[0008-0011,0448-0451,3508-3511,4278-4279]
```

- `ps -u course93` only return my processes, not entirely sure of the equivalent command to `sinfo -p debug`. Since `sinfo -p debug -u course93` does not work....

- We can use `sbatch <filename> -e <errorfile>` to change the error file directory and `sbatch <filename> -o <outputfile>`

- Getting following error when running 

  ```
  sbatch: error: The project crs03 either specified at submission time, or your default, is expired. You cannot submit jobs for this project.
  sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified
  ```

  