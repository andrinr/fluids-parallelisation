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

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun /users/course93/hpc_esc401/exercise_session_02/cpi_mpi.c
