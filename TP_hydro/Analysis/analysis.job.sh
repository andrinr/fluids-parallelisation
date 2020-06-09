#!/bin/bash -l
#SBATCH --job-name="weak-5" 
#SBATCH --time=00:04:00 
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun ../Bin/hydro test_5.nml 11
