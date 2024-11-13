#!/bin/bash

#SBATCH --job-name=gromacs_job
#SBATCH --output=log.%x.%a.out
#SBATCH --error=log.%x.%a.err

#SBATCH --partition=irb_cpu_iclk
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00


#GROMACS-PLUMED for intel and amd_zen4 nodes
spack load gromacs /k37774t

#GROMACS v2023.4 (without plumed patch) for amd_zen2 and amd_zen3 nodes
#spack load gromacs /54fsu4m 


#GROMACS-PLUMED for amd_zen2 and amd_zen3 nodes
#compiler: aocc@4.1.0 , dependencies: amdlibflame amdblis amdfftw
#spack load gromacs /fpkmp2k

#compiler: gcc@13.2.0 , dependencies: amdfftw (better performance in test benchPEP-h)
#spack load gromacs /xccghyt

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PLACES=cores
export OMP_PROC_BIND=spread
export OMPI_MCA_plm=slurm

hostlist=$(scontrol show hostname $SLURM_JOB_NODELIST | awk '{printf "%s:64,", $1}' | sed 's/,$//')

# Run the GROMACS job with explicit CPU binding using openmpi flags
mpirun --bind-to core --map-by numa:PE=$SLURM_CPUS_PER_TASK -n $SLURM_NTASKS gmx_mpi mdrun -pin on -ntomp $SLURM_CPUS_PER_TASK <..>
