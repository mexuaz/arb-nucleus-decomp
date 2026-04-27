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
GRAPH_PATH="${1:-}"
THREADS="${SLURM_CPUS_PER_TASK:-56}"
BAZEL_BIN="${BAZEL_BIN:-$HOME/.local/bin/bazelisk}"
BAZEL_VERSION="${BAZEL_VERSION:-2.1.0}"

if [[ -z "$GRAPH_PATH" ]]; then
  echo "Usage: sbatch $0 /path/to/gbbs_graph"
  exit 1
fi

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

srun --cpu-bind=cores "$RUNNER" "${RUN_ARGS[@]}" "$GRAPH_PATH"
