#!/bin/bash
#SBATCH -A m5152
#SBATCH -C cpu
#SBATCH -q regular
#SBATCH -N 16                # 4 runs × 4 nodes each
#SBATCH -t 06:00:00
#SBATCH -J VASP_CPU_MULTI
#SBATCH -o VASP_CPU_MULTI-%j.out
#SBATCH -e VASP_CPU_MULTI-%j.err

module load vasp/6.4.3-cpu

# Recommended CPU settings
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

cd "${SLURM_SUBMIT_DIR}" || exit 1

echo "JOBID: ${SLURM_JOB_ID}"
echo "Launching concurrent CPU runs..."

# ---- Per-run configuration ----
# 4 nodes per run
# 128 cores per node
# 4 nodes → 512 MPI ranks

SRUN_COMMON=(
  --exclusive
  -N 4
  -n 512
  -c 1
  --cpu-bind=cores
)

launch_one () {
  local d="$1"
  echo "[LAUNCH] $d"
  (
    cd "$d" || exit 2
    echo "START $(date)  $(pwd)" > vasp.runlog
    srun "${SRUN_COMMON[@]}" vasp_std > vasp.out 2> vasp.err
    rc=$?
    echo "END   $(date)  rc=${rc}" >> vasp.runlog
    exit $rc
  ) &
}

# ---- Paste directories below ----

launch_one "disp-678"
launch_one "disp-679"
launch_one "disp-680"
launch_one "disp-681"

echo "All runs launched. Waiting..."
wait
echo "All runs finished."

