#!/bin/bash

#SBATCH --job-name=kars_s-s_rep2
#SBATCH --output=log.%x.%a.out
#SBATCH --error=log.%x.%a.err

#SBATCH --partition irb_gpu_3090
#SBATCH --gres gpu:1

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=160:00:00

#for irbgcn01 node (RTX3090 - amd-zen)
spack load amber24/lym3pj3

#for irbgcn[02-04] nodea (RTX2080 - intel)
#spack load amber24/75a75vs

pmemd.cuda -O -i md.in -o md.out -p kars_s-s_1264.parm7 -c md_NPT_300.rst7 -r md.rst7 -x md.nc -inf md.info



