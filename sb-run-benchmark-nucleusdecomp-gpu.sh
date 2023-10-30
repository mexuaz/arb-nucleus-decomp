#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=benchmark-arb-nucleus-decomp-gpu-%j
#SBATCH --output=benchmark-arb-nucleus-decomp-gpu-%j.out
#SBATCH --error=benchmark-arb-nucleus-decomp-gpu-%j.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --gres=cpu:16 # Number of CPUs (shared or exclusive)
#SBATCH --gres=gpu:1 # Number of GPUs (per node)
#SBATCH --mem=48G # Memory per node (Max memory on Cascade Lake with GPU 187G)
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=10:00:00 # Time limit hrs:min:sec
#SBATCH --constraint=cascade # define specific Node

#rm benchmark-arb-nucleus-decomp-gpu*.out benchmark-arb-nucleus-decomp-gpu*.err
module load StdEnv/2020 gcc/9.3.0 cuda/12.2 cmake/3.23.1 bazel/3.6.0 

DATASETS=("cit-Patents.adj" "soc-LiveJournal1.adj" "wiki-Vote.adj")
PWD="../datasets"

for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started with NucleusDecomposition_main ..."
    # Runing benchmark with Bazel
    bazel run :NucleusDecomposition_main -- -s -rounds 1 --rClique 3 --sClique 4 --numberOfLevels TWO_LEVEL --inverseIndexMap STORED_POINTERS --relabel --updateAggregation LIST_BUFFER "${PWD}/${GRAPH}.adj"
    echo "Benchmarking graph $GRAPH finished."
done