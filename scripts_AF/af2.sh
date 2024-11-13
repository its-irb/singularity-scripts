#!/bin/bash

#SBATCH -e %j.err
#SBATCH -o %j.out
#SBATCH --job-name AF2_test
#SBATCH --time=24:00:00
#SBATCH --gres=gpu:1
#SBATCH -c 12
#SBATCH --mem-per-cpu=6G

# Env vars
export ALPHAFOLD_DATA_PATH="/apps/alpha_fold"
export ALPHAFOLD_MODELS="/apps/alpha_fold/params"

# Singularity execution
singularity run --nv --writable-tmpfs \
-B $ALPHAFOLD_DATA_PATH:/data \
-B $ALPHAFOLD_MODELS \
-B /home/$USER/tmp:/etc \
-B /scratch\ 
-B /data\
--pwd /app/alphafold /apps/singularity/docker_irb_alphafold.sif \
--data_dir=/data \
--output_dir=/scratch/mmb/hospital/Tests_AF2 \
--fasta_paths=/scratch/mmb/hospital/Tests_AF2/1a32.fa  \
--uniref90_database_path=/data/uniref90/uniref90.fasta  \
--mgnify_database_path=/data/mgnify/mgy_clusters_2022_05.fa \
--template_mmcif_dir=/data/pdb_mmcif/mmcif_files  \
--obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat \
--max_template_date=2020-05-14 \
--db_preset=full_dbs \
--bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
--uniref30_database_path=/data/uniref30/UniRef30_2021_03 \
--model_preset=monomer \
--pdb70_database_path=/data/pdb70/pdb70 \
--use_gpu_relax

