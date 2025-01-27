#!/bin/bash

#SBATCH --chdir=/scratch/its/ibosch
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --mem=240G
#SBATCH -w irbccn06
#SBATCH -o af.out
#SBATCH -e af.err
#SBATCH -t 24:00:00
#SBATCH --distribution=block:block:block

#mkdir -p /scratch/its/ibosch/intel_output_alphafold/
#mkdir -p scratch/its/ibosch/intel_inp_fasta/
#mkdir -p /scratch/its/ibosch/intel_log_alphafold/

export OUTPUT_DIR=/scratch/its/ibosch/intel_output_alphafold/
export DATA_DIR=/apps/alpha_fold
export SAMPLES_DIR=/scratch/its/ibosch/intel_inp_fasta/
export LOG_DIR=/scratch/its/ibosch/intel_log_alphafold/


singularity exec  -B $DATA_DIR:/data -B $SAMPLES_DIR:/samples -B $OUTPUT_DIR:/output -B $LOG_DIR:/Open-Omics-Acceleration-Framework/applications/alphafold/logs --pwd /Open-Omics-Acceleration-Framework/applications/alphafold intel_af_v2.sif python run_multiprocess_pre.py --root_home=/Open-Omics-Acceleration-Framework/applications/alphafold --data_dir=/data --input_dir=/samples --output_dir=/output --model_name=model_1

singularity exec  -B $DATA_DIR:/data -B $SAMPLES_DIR:/samples -B $OUTPUT_DIR:/output -B $LOG_DIR:/Open-Omics-Acceleration-Framework/applications/alphafold/logs --pwd /Open-Omics-Acceleration-Framework/applications/alphafold --env LD_PRELOAD=/opt/conda/lib/libiomp5.so:/opt/conda/lib/libjemalloc.so:$LD_PRELOAD --env MALLOC_CONF="oversize_threshold:1,background_thread:true,metadata_thp:auto,dirty_decay_ms:-1,muzzy_decay_ms:-1" intel_af_v2.sif python run_multiprocess_infer.py --root_condaenv=/opt/conda --root_home=/Open-Omics-Acceleration-Framework/applications/alphafold --data_dir=/data --input_dir=/samples --output_dir=/output --model_names=model_1
