#!/bin/bash -l
#SBATCH --job-name="weak-8" 
#SBATCH --time=00:04:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread

export OMP_NUM_THREADS=256

srun ../Bin/hydro test_8.nml 19
