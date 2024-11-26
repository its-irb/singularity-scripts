#!/bin/bash
#SBATCH --job-name=openmm_job
#SBATCH --output=log.%j.out
#SBATCH --error=log.%j.err

#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=24:00:00


### CUDA_VERSION=12.0
### OPENMM_VERSION=8.1.1
### PLUMED_VERSION=2.9.0
### OPENMM-PLUMED_VERSION=2.0.1
### PYTHON_VERSION=3.10 and also installed parmed==4.3.0 mdtraj==1.9.9 numpy=1.21.5
### NO multi-node support


SINGULARITY_IMAGE="/apps/singularity/openmm_8.1.1_plumed_2.9.0_openmm-plumed_2.0.1.sif"
SINGULARITY_BINDPATH="/apps:/apps,/data:/data,/home:/home"

#python script.py importing openmm, openmm-plumed, mdtraj and parmed modules
singularity exec --nv --cleanenv python /path/to/script.py 
