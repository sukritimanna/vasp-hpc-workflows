#!/bin/bash
#SBATCH -A m5152
#SBATCH -C gpu
#SBATCH -q premium
#SBATCH -N 18                 # 9 runs × 2 nodes each
#SBATCH -t 24:00:00
#SBATCH -J VASP_GPU_MULTI
#SBATCH -o multi-%j.out
#SBATCH -e multi-%j.err
#SBATCH --gpus-per-node=4

module load vasp/6.4.3-gpu

# Recommended OpenMP settings for Perlmutter GPU
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

cd "${SLURM_SUBMIT_DIR}" || exit 1
echo "JOBID: ${SLURM_JOB_ID}"
echo "Launching concurrent 2-node VASP runs..."

# -------------------------------------------------
# 2 nodes = 8 GPUs
# 8 MPI ranks (4 per node), 1 GPU per rank
# -------------------------------------------------
SRUN_COMMON=(
  --exclusive
  -N 2
  --ntasks=8
  --ntasks-per-node=4
  --gpus=8
  --gpus-per-task=1
  --cpus-per-task=16
  --cpu-bind=cores
  --gpu-bind=none
)

launch_one () {
  local d="$1"
  echo "[LAUNCH] $d"
  (
    cd "$d" || exit 2
    echo "START $(date)" > vasp.runlog
    srun "${SRUN_COMMON[@]}" vasp_std > vasp.out 2> vasp.err
    rc=$?
    echo "END   $(date) rc=${rc}" >> vasp.runlog
    exit $rc
  ) &
}

# -------------------------------
# Paste your directories below
# -------------------------------

launch_one "/path/to/run1"
launch_one "/path/to/run2"
launch_one "/path/to/run3"
launch_one "/path/to/run4"
launch_one "/path/to/run5"
launch_one "/path/to/run6"
launch_one "/path/to/run7"
launch_one "/path/to/run8"
launch_one "/path/to/run9"

echo "All runs launched. Waiting..."
wait
echo "All runs finished."

