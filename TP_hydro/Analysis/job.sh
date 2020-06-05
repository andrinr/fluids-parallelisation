#!/bin/bash -l
#SBATCH --job-name="strong scaling"
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread

export OMP_NUM_THREADS=1

srun ../Bin/hydro