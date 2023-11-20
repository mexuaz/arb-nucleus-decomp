#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=bmk-arb-nucleus-decomp-cpu-%j
#SBATCH --output=bmk-arb-nucleus-decomp-cpu-%j.out
#SBATCH --error=bmk-arb-nucleus-decomp-cpu-%j.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --gres=cpu:32 # Number of CPUs (shared or exclusive)
#SBATCH --mem=64G # Memory per node (Max memory on Cascade Lake with GPU 187G)
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=5:00:00 # Time limit hrs:min:sec

echo "Benchmarking arb-nucleus-decomp-cpu started ..."

echo "Clearing old output files ..."
rm benchmark-arb-nucleus-decomp-cpu*.out benchmark-arb-nucleus-decomp-cpu*.err

echo "Loading modules ..."
module purge; module load StdEnv/2023 cmake/3.27.7 gcc/12.3 java/17.0.6 python/3.11.5

DATASETS=("cit-Patents.txt.adj" "soc-LiveJournal1.txt.adj" "wiki-Vote.txt.adj")
PWD="../datasets"

for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started ..."
    ./build/benchmarks/NucleusDecomposition/NucleusDecomposition -- -s -rounds 1 --rClique 3 --sClique 4 --numberOfLevels TWO_LEVEL --inverseIndexMap STORED_POINTERS --relabel --updateAggregation LIST_BUFFER ${PWD}/${GRAPH}
    echo "Benchmarking graph $GRAPH finished."
done