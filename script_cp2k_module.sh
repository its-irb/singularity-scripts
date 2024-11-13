#!/bin/sh
#SBATCH --job-name=test-cp2k
#SBATCH --error=/home/ibosch/cp2k_benchmark/benchmark.err
#SBATCH -o /home/ibosch/cp2k_benchmark/benchmark.out
#SBATCH -c 1
#SBATCH -n 224
#SBATCH --time=12:00:00
#SBATCH -p mmb_cpu_sphr
#SBATCH --prefer=sph
#SBATCH --mem-per-cpu=2G

#!/bin/bash

spack load cp2k

BASE_INPUT="/home/ibosch/cp2k_benchmark/QS"
VARIANTS=("H2O-32.inp" "H2O-64.inp" "H2O-128.inp" "H2O-256.inp" "H2O-512.inp")

for VARIANT in "${VARIANTS[@]}"
do
    INPUT="$BASE_INPUT/$VARIANT"
    OUTPUT="cp2k-${SLURM_NTASKS}-tasks-${VARIANT}-$SLURM_JOB_ID.out"
    OUTPUT2="results-intel-${SLURM_NTASKS}-${VARIANT}.out"

    export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
    export OMP_PLACES=cores

    echo "INPUT=$INPUT"
    echo "SLURM_NNODES=$SLURM_NNODES"
    echo "NTASKS=$SLURM_NTASKS"
    echo "THREADS=$SLURM_CPUS_PER_TASK"

    mpirun -n $SLURM_NTASKS cp2k.psmp -i $INPUT -o $OUTPUT

    cat $OUTPUT | grep "CPU time per MD step" > $OUTPUT2
    cat $OUTPUT | grep "STARTED AT" >> $OUTPUT2
    cat $OUTPUT | grep "ENDED AT" >> $OUTPUT2

    inicio=$(grep -Eo 'PROGRAM STARTED AT\s+([0-9-]+)\s+([0-9:.]+)' $OUTPUT2 | awk '{print $4, $5}')
    fin=$(grep -Eo 'PROGRAM ENDED AT\s+([0-9-]+)\s+([0-9:.]+)' $OUTPUT2 | awk '{print $4, $5}')
    tiempo_inicio=$(date -d "$inicio" +"%s")
    tiempo_fin=$(date -d "$fin" +"%s")

    diferencia=$((tiempo_fin - tiempo_inicio))

    echo "TIME: $diferencia s" >> $OUTPUT2
done

