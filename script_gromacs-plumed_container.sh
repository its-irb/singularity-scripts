#!/bin/bash
#SBATCH --job-name=gromacs_job
#SBATCH --output=log.%x.%a.out
#SBATCH --error=log.%x.%a.err

#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=60:00:00


### This gromacs container is installed with and CUDA
### CUDA_VERSION=12.3.1
### GROMACS_VERSION=2023.2
### PLUMED_VERSION=2.10 
### NO multi-node support
### Available gmx and gmx_d (double precision, does not support gpu) commands

### This script run GROMACS using 1 GPU & 1 thread-MPI tasks & 8 OpenMP threads per thread-MPI task 

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PLACES=cores
export OMP_PROC_BIND=true

export GMX_ENABLE_DIRECT_GPU_COMM=1

SINGULARITY_IMAGE="/apps/singularity/gromacs_2023.2.sif"

###with PLUMED####
#SINGULARITY_IMAGE="/apps/singularity/gromacs-plumed-mpich.sif"
#SINGULARITY_IMAGE="/apps/singularity/gromacs-plumed-openmp.sif"

pre_gmx="singularity run --nv -B /scratch -B /apps -B /data -B ${PWD}:/host_pwd --pwd /host_pwd $SINGULARITY_IMAGE"

#for gromacs-plumed
#pre_gmx="singularity run --nv -B /scratch -B /apps -B /data -B ${PWD}:/work --pwd /work $SINGULARITY_IMAGE"

$pre_gmx gmx mdrun -ntomp $SLURM_CPUS_PER_TASK -nb gpu  <...>
~                   
