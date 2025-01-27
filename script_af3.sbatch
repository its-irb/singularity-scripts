#!/bin/bash
#SBATCH --job-name=alphafold3_pipeline
#SBATCH --output=alphafold3_%j.out
#SBATCH --error=alphafold3_%j.err
#SBATCH -t 24:00:00

# Directories
INPUT_DIR="/data/its/ibosch/af3_test/af3_input"
OUTPUT_DIR="/data/its/ibosch/af3_test/af3_output"
MODEL_DIR="/apps/alphafold3/af3_model"
DB_DIR="/apps/alphafold3/af3_db"
CONTAINER="/apps/singularity/docker_irb_af3.sif"

# Step 1: MSA Computation (CPU node)
MSA_JOB_ID=$(sbatch --parsable <<EOF
#!/bin/bash
#SBATCH --job-name=alphafold3_msa
#SBATCH -c 9
#SBATCH --mem=40G
#SBATCH -p mmb_cpu_zen3
#SBATCH --time=4:00:00
#SBATCH --output=msa_%j.out
#SBATCH --error=msa_%j.err

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
    --db_dir=/root/public_databases
EOF
)

echo "MSA job submitted with ID: $MSA_JOB_ID"

# Step 2: Structure Inference (GPU node) - depends on MSA completion
sbatch --dependency=afterok:$MSA_JOB_ID <<EOF
#!/bin/bash
#SBATCH --job-name=alphafold3_inference
#SBATCH -G 1
#SBATCH -c 2
#SBATCH --mem=40G
#SBATCH --time=8:00:00
#SBATCH --output=inference_%j.out
#SBATCH --error=inference_%j.err

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
EOF

echo "Inference job will run after MSA job completes."
