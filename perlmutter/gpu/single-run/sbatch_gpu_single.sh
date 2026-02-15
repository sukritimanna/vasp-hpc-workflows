#!/bin/bash
#SBATCH -A m5152
#SBATCH -C gpu
#SBATCH -q premium
#SBATCH -N 2
#SBATCH -t 24:00:00
#SBATCH -J VASP_GPU_SINGLE
#SBATCH -o vasp-%j.out
#SBATCH -e vasp-%j.err
#SBATCH --gpus-per-node=4

module load vasp/6.4.3-gpu

# OpenMP settings (recommended for Perlmutter GPU)
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

cd "${SLURM_SUBMIT_DIR}" || exit 1
echo "Running in: $(pwd)"
echo "JobID: ${SLURM_JOB_ID}"

# 2 nodes = 8 GPUs total
srun --exclusive \
     -N 2 \
     --ntasks=8 \
     --ntasks-per-node=4 \
     --gpus=8 \
     --gpus-per-task=1 \
     --cpus-per-task=16 \
     --cpu-bind=cores \
     --gpu-bind=none \
     vasp_std > vasp.out 2> vasp.err

echo "Done."

