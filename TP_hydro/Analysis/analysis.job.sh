#!/bin/bash -l
#SBATCH --job-name="weak-5" 
#SBATCH --time=00:05:00
#SBATCH --nodes=32
#SBATCH --ntasks-per-core=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo $SLURM_CPUS_PER_TASK

srun ../Bin/hydro test.nml 11
