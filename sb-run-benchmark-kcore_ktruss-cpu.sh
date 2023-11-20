#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=bmk-kcore-ktruss-gpu-%j
#SBATCH --output=bmk-kcore-ktruss-gpu-%j.out
#SBATCH --error=bmk-kcore-ktruss-gpu-%j.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --gres=cpu:16 # Number of CPUs (shared or exclusive)
#SBATCH --gres=gpu:1 # Number of GPUs (per node)
#SBATCH --mem=32G # Memory per node
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=5:00:00 # Time limit hrs:min:sec


#rm benchmark-arb-nucleus-decomp-gpu*.out benchmark-arb-nucleus-decomp-gpu*.err
module load StdEnv/2020 gcc/9.3.0 cuda/12.2 cmake/3.23.1 bazel/3.6.0 
cd benchmarks/KTruss

DATASETS=("cit-Patents.txt.adj" "soc-LiveJournal1.txt.adj" "wiki-Vote.txt.adj")
DATADIR="../../../datasets"

for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started with KTruss ..."
    time -v ./KTruss -s "${DATADIR}/${GRAPH}"
    echo "Benchmarking graph $GRAPH with KTruss finished."
done

DATASETS=("cit-Patents.txt" "soc-LiveJournal1.txt" "wiki-Vote.txt")

cd ../KCore/JulienneDBS17
for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started with KCore ..."
    time -v ./KCore -s "${DATADIR}/${GRAPH}"
    echo "Benchmarking graph $GRAPH with KCore finished."
done