#!/bin/sh
#SBATCH --job-name=test-cp2k
#SBATCH -o benchmark.out
#SBATCH -e benchmark.err
#SBATCH -c 1
#SBATCH -n 112
#SBATCH -N 2
#SBATCH --partition=mmb_cpu_sphr
#SBATCH --ntasks-per-node=56
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=2G

VARIANT=H2O-512.inp

BASE_INPUT=/home/ibosch/cp2k_benchmark/QS

INPUT=$BASE_INPUT/$VARIANT
OUTPUT=cp2k-${SLURM_NTASKS}-tasks-${VARIANT}-$SLURM_JOB_ID.out
OUTPUT2=results-mmb2-${SLURM_NNODES}-${SLURM_NTASKS}-${SLURM_CPUS_PER_TASK}.out

#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
#export OMP_PLACES=cores
#export OMP_PROC_BIND=true

spack load mpich@4.1.2 %intel arch=linux-rocky8-sapphirerapids

mpirun -n $SLURM_NTASKS --bind-to core singularity run --writable-tmpfs -B /home -B /scratch -B /apps -B /data /apps/singularity/cp2k_2024.1_mpich_generic_psmp.sif cp2k -i $INPUT -o $OUTPUT

cat $OUTPUT | grep "CPU time per MD step" > $OUTPUT2
cat $OUTPUT | grep "STARTED AT" >> $OUTPUT2
cat $OUTPUT | grep "ENDED AT" >> $OUTPUT2

