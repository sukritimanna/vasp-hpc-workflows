#!/bin/bash
#SBATCH -A m5152
#SBATCH -N 4
#SBATCH -J Job_single
#SBATCH -C cpu
#SBATCH -q regular
#SBATCH -t 02:00:00
#SBATCH -o Job_single.%j.out
#SBATCH -e Job_single.%j.err

module load vasp/6.4.3-cpu

# Recommended CPU settings
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

echo "JOBID: ${SLURM_JOB_ID}"
echo "Running from: ${SLURM_SUBMIT_DIR}"
echo "START: $(date)"

# Move to directory where sbatch was executed
cd "${SLURM_SUBMIT_DIR}" || exit 1

# Perlmutter CPU node = 128 cores
# 4 nodes → 512 total cores

srun -N 4 -n512 -c1 --cpu-bind=cores vasp_std > vasp.out 2> vasp.err

echo "END: $(date)"

