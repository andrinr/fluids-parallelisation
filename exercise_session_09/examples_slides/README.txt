Instructions to compile and run CUDA codes in Piz-Daint.

1.- Load the proper modules:
module load daint-gpu
module load cudatoolkit

2.- Try compiling the example provided:
nvcc hello_world.cu

3.- In order to run on a GPU, we first need to allocate a node with a GPU.
    We will launch an interactive job:
srun --pty -A uzg2 --contraint=gpu bash

4.- Once the job has been allocated we can proceed to execute the code:
./a.out