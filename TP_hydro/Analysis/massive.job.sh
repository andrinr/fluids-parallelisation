#!/bin/bash -l
#SBATCH --job-name="massive" 
#SBATCH --time=00:20:00
#SBATCH --nodes=32
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=12
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --hint=nomultithread
#SBATCH --account=uzg2

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun ../Bin/hydro ../Input/test.nml
