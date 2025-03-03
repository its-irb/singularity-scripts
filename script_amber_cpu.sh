#!/bin/sh
#SBATCH --job-name=amber_job_cpu
#SBATCH --output=log.%x.%j.%N.out
#SBATCH --error=log.%x.%j.%N.err

#SBATCH --partition=irb_cpu_sphr

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mem=120G
#SBATCH --time=300:00:00

###check in the documentation which amber version in https://irb.app.lumapps.com/home/ls/content/amber-24-usage

ulimit -Ss unlimited
export OMP_PLACES=CORES
export OMP_PROC_BIND=SPREAD
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

hostlist=$(scontrol show hostname $SLURM_JOB_NODELIST | awk '{printf "%s:64,", $1}' | sed 's/,$//')

mpirun -np $((SLURM_NTASKS_PER_NODE * SLURM_JOB_NUM_NODES)) \
       --map-by numa:PE=${SLURM_CPUS_PER_TASK} \
       --bind-to core \
       --host $hostlist \
       sander.MPI -O -i input.in -p topology.parm7 -c coords.inpcrd -r restart.rst7 -o output.out -x traj.nc -inf info_file.info

