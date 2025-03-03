#!/bin/bash
#SBATCH --job-name=alphafold3_pipeline
#SBATCH --output=alphafold3_%j.out
#SBATCH --error=alphafold3_%j.err
#SBATCH -t 24:00:00

# Directories
INPUT_DIR="/data/its/ibosch/af3_test/af3_input"
OUTPUT_DIR="/data/its/ibosch/af3_test/af3_output"
CONTAINER="/apps/singularity/docker_irb_af3.sif"

# read documentation https://irb.app.lumapps.com/home/ls/content/af-3-data-pipeline

#####################
# db stored in /apps (NetApp)
#####################
MODEL_DIR="/apps/alphafold3/af3_model"
DB_DIR="/apps/alphafold3/af3_db"

#####################
# db stored in /scratch
#####################
#MODEL_DIR="/scratch/alphafold3/af3_model"
#DB_DIR="/scratch/alphafold3/af3_db"

#####################
# db stored in s3 (minio)
#####################
#MODEL_DIR="$HOME/af3minio/af3_model"
#DB_DIR="$HOME/af3minio/af3_db"

# Step 1: data pipeline computation (CPU node)
MSA_JOB_ID=$(sbatch --parsable <<EOF
#!/bin/bash
#SBATCH --job-name=alphafold3_msa
#SBATCH -c 9
#SBATCH --mem=40G
#SBATCH -p irb_cpu_sphr
#SBATCH --time=24:00:00
#SBATCH --output=msa_%j.out
#SBATCH --error=msa_%j.err

#####################
# if use db stored in s3 -> mount af3 db stored in s3 (minio)
#####################
#ml load anaconda3
#conda activate s3-minio
#mkdir -p $HOME/af3minio
#rclone mount irb-minio:scicom $HOME/af3minio --read-only --vfs-cache-mode off &
#sleep 10
#conda deactivate
#ml purge

singularity run \
  --pwd /app/alphafold/ \
  -B ${INPUT_DIR}:/root/af_input \
  -B ${OUTPUT_DIR}:/root/af_output \
  -B ${MODEL_DIR}:/root/models \
  -B ${DB_DIR}:/root/public_databases \
  ${CONTAINER} \
  python run_alphafold.py \
    --json_path=/root/af_input/fold_input.json \
    --model_dir=/root/models \
    --output_dir=/root/af_output \
    --run_inference=false \
    --db_dir=/root/public_databases \
    --jackhmmer_n_cpu=2

#####################
# if use db stored in s3 -> umount s3 volume
#####################
#fusermount -u $HOME/af3minio
EOF
)

echo "data pipeline submitted with ID: $MSA_JOB_ID"

# Step 2: Structure Inference (GPU node) - depends on data pipeline completion
sbatch --dependency=afterok:$MSA_JOB_ID <<EOF
#!/bin/bash
#SBATCH --job-name=alphafold3_inference
#SBATCH -G 1
#SBATCH -c 2
#SBATCH --mem=40G
#SBATCH --time=24:00:00
#SBATCH --output=inference_%j.out
#SBATCH --error=inference_%j.err

#####################
# if use db stored in s3 -> mount af3 db stored in s3 (minio)
#####################
#ml load anaconda3
#conda activate s3-minio
#mkdir -p $HOME/af3minio
#rclone mount irb-minio:scicom $HOME/af3minio --read-only --vfs-cache-mode off &
#sleep 10
#conda deactivate
#ml purge

singularity run \
  --nv --pwd /app/alphafold/ \
  -B ${INPUT_DIR}:/root/af_input \
  -B ${OUTPUT_DIR}:/root/af_output \
  -B ${MODEL_DIR}:/root/models \
  -B ${DB_DIR}:/root/public_databases \
  ${CONTAINER} \
  python run_alphafold.py \
    --json_path=/root/af_output/2pv7/2pv7_data.json \
    --model_dir=/root/models \
    --output_dir=/root/af_output \
    --run_data_pipeline=false \
    --db_dir=/root/public_databases

#####################
# if use db stored in s3 -> umount s3 volume
#####################
#fusermount -u $HOME/af3minio
EOF

echo "Inference job will run after data pipeline job completes."
