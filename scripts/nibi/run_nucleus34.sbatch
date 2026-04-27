#!/usr/bin/env bash
#SBATCH --account=def-thomo
#SBATCH --job-name=JeShiNucleus34
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=0-03:00          # time (DD-HH:MM)
#SBATCH --nodes=1               # Forces the job to run on exactly one physical node
#SBATCH --ntasks=1              # Single task for the whole node
#SBATCH --cpus-per-task=56      # Nibi H100 nodes (g*) have 112 CPUs total: 2 sockets x 56 cores x 1 thread
#SBATCH --mem=224G              # There are 4G per CPU so totaling 224G

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATASET_ROOT="$REPO_ROOT/src/build/datasets"
GRAPH_SELECTOR="${1:-}"
THREADS="${SLURM_CPUS_PER_TASK:-56}"
BAZEL_BIN="${BAZEL_BIN:-$HOME/.local/bin/bazelisk}"
BAZEL_VERSION="${BAZEL_VERSION:-2.1.0}"
RESULTS_ROOT="${SLURM_SUBMIT_DIR:-$REPO_ROOT}/results"
RESULTS_DIR="$RESULTS_ROOT/${SLURM_JOB_NAME:-JeShiNucleus34}-${SLURM_JOB_ID:-manual}"

LARGE_DATASETS=(
  "amazon-2008.mtx" # 1
  "soc-Slashdot0811.mtx" # 2
  "soc-FourSquare.mtx" # 3
  "cit-patent.edges" # 4
  "soc-BlogCatalog.mtx" # 5
  "soc-LiveJournal1.edges" # 6
)

resolve_large_dataset() {
  local selector="$1"

  if [[ "$selector" =~ ^[0-9]+$ ]]; then
    local index="$selector"
    if (( index < 1 || index > ${#LARGE_DATASETS[@]} )); then
      echo "Invalid dataset index: $index (valid range: 1-${#LARGE_DATASETS[@]})" >&2
      return 1
    fi
    printf '%s\n' "${LARGE_DATASETS[index - 1]}"
  else
    printf '%s\n' "$selector"
  fi
}

load_first_module() {
  local module_name
  for module_name in "$@"; do
    if module load "$module_name" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

if command -v module >/dev/null 2>&1; then
  module purge || true
  module spider bazel || true
  module spider gcc || true
  load_first_module stdenv/2023 StdEnv/2023 StdEnv/2020 || true
  load_first_module gcc/12.3.0 gcc/11.4.0 gcc/10.3.0 gcc || true
fi

if [[ ! -x "$BAZEL_BIN" ]]; then
  mkdir -p "$(dirname "$BAZEL_BIN")"
  curl -L --fail -o "$BAZEL_BIN" \
    "https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-amd64"
  chmod +x "$BAZEL_BIN"
fi

export USE_BAZEL_VERSION="$BAZEL_VERSION"
export NUM_THREADS="$THREADS"
export OMP_NUM_THREADS="$THREADS"

cd "$REPO_ROOT"

mkdir -p "$RESULTS_DIR"

RUNNER="$REPO_ROOT/bazel-bin/benchmarks/NucleusDecomposition/NucleusDecomposition_main"

if [[ ! -x "$RUNNER" ]]; then
  "$BAZEL_BIN" build //benchmarks/NucleusDecomposition:NucleusDecomposition_main
fi

RUN_ARGS=(
  # Input graph is symmetric/undirected.
  -s
  # Run a single benchmark repetition.
  -rounds 1
  # Set r = 3 in the (r, s)-nucleus decomposition.
  -r 3
  # Set s = 4 in the (r, s)-nucleus decomposition.
  -ss 4
  # Use the list-buffer strategy for tracking updated r-cliques.
  -efficient 1
  # Enable the graph relabeling optimization.
  -relabel
)

run_one_graph() {
  local graph_path="$1"
  local result_tag="$2"
  local result_file="$RESULTS_DIR/${result_tag}-$(date +%Y%m%dT%H%M%S).json"

  if [[ ! -f "$graph_path" ]]; then
    echo "Graph file not found: $graph_path" >&2
    return 1
  fi

  set +e
  srun --cpu-bind=cores "$RUNNER" "${RUN_ARGS[@]}" "$graph_path" | tee "$result_file"
  local run_status=${PIPESTATUS[0]}
  local tee_status=${PIPESTATUS[1]}
  set -e

  if [[ $run_status -ne 0 ]]; then
    return "$run_status"
  fi

  return "$tee_status"
}

if [[ -z "$GRAPH_SELECTOR" ]]; then
  exit_code=0
  for graph_name in "${LARGE_DATASETS[@]}"; do
    graph_path="$DATASET_ROOT/$graph_name"
    result_tag="dataset-${graph_name}-t${THREADS}"
    set +e
    run_one_graph "$graph_path" "$result_tag"
    run_status=$?
    set -e
    if [[ $run_status -ne 0 ]]; then
      exit_code=$run_status
    fi
  done
  exit "$exit_code"
fi

if [[ "$GRAPH_SELECTOR" =~ ^[0-9]+$ ]]; then
  GRAPH_NAME="$(resolve_large_dataset "$GRAPH_SELECTOR")"
  GRAPH_PATH="$DATASET_ROOT/$GRAPH_NAME"
  RESULT_TAG="dataset-${GRAPH_SELECTOR}-${GRAPH_NAME}-t${THREADS}"
else
  GRAPH_PATH="$GRAPH_SELECTOR"
  RESULT_TAG="$(basename "${GRAPH_PATH%.*}")-t${THREADS}"
fi

set +e
run_one_graph "$GRAPH_PATH" "$RESULT_TAG"
run_status=$?
set -e
exit "$run_status"
