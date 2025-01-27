#!/bin/bash

#SBATCH --job-name MSA_AF_berz
#SBATCH --chdir=/scratch/its/ibosch
#SBATCH --time=72:00:00
#SBATCH -p mmb_cpu_sphr
#SBATCH -N 1
#######SBATCH --gres gpu:1
#SBATCH -c 32
#SBATCH --mem-per-cpu=3G

# Definir las variables de entorno
export ALPHAFOLD_DATA_PATH="/apps/alpha_fold"


#mkdir -p /scratch/its/ibosch/berz_out
#mkdir -p /scratch/its/ibosch/berz_in
export INPUT=/scratch/its/ibosch/berz_in/T1050.fasta
export OUTPUT_DIR=/scratch/its/ibosch/berz_out

# Ejecutar el contenedor Singularity
singularity exec --writable-tmpfs \
-B $ALPHAFOLD_DATA_PATH:/data \
-B /tmp:/etc \
-B /scratch \
--env ALPHAFOLD_PREFIX="/app" \
/apps/singularity/docker_irb_berzelius_af.sif \
/app/run_alphafold.sh   -d  /data   -o $OUTPUT_DIR  -f $INPUT -r best  -t 2021-11-01   -g false   -P 3   -F true

# r means model to relax <all|best|none>
# g relax on gpu
# P num o MSA parallelized processes (best performance P=3)
# -F true only run MSA part
