#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=bmk-arb-nucleus-decomp-gpu-%j
#SBATCH --output=bmk-arb-nucleus-decomp-gpu-%j.out
#SBATCH --error=bmk-arb-nucleus-decomp-gpu-%j.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --cpus-per-task=16 # Number of CPUs per task
#SBATCH --mem-per-cpu=4G # Memory per CPU
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=8:00:00 # Time limit hrs:min:sec

echo "Benchmarking arb-nucleus-decomp-cpu started ..."

echo "Clearing old output files ..."
rm benchmark-arb-nucleus-decomp-cpu*.out benchmark-arb-nucleus-decomp-cpu*.err

echo "Loading modules ..."
module purge; module load StdEnv/2023 cmake/3.27.7 gcc/12.3 java/17.0.6 python/3.11.5

DATASETS=("amazon-2008.txt" "cit-Patents.txt" "soc-BlogCatalog.txt" "soc-FourSquare.txt" "soc-digg.txt" "soc-livejournal.txt" "wiki-Vote.txt")
PWD="../datasets"

for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started ..."
    ./build/benchmarks/NucleusDecomposition/NucleusDecomposition -- -s -rounds 1 --rClique 3 --sClique 4 --numberOfLevels TWO_LEVEL --inverseIndexMap STORED_POINTERS --relabel --updateAggregation LIST_BUFFER ${PWD}/${GRAPH}.adj
    echo "Benchmarking graph $GRAPH finished."
done