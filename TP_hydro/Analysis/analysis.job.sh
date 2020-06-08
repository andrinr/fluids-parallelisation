#!/bin/bash -l
#SBATCH --job-name="hybrid_test"                                                                         
#SBATCH --time=00:02:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun ../Bin/hydro "input.nml"
