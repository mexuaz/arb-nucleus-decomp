#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=benchmark-arb-nucleus-decomp-gpu-%j
#SBATCH --output=benchmark-arb-nucleus-decomp-gpu-%j.out
#SBATCH --error=benchmark-arb-nucleus-decomp-gpu-%j.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --gres=cpu:32 # Number of CPUs (shared or exclusive)
#SBATCH --gres=gpu:1 # Number of GPUs (per node)
#SBATCH --mem=64G # Memory per node
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=5:00:00 # Time limit hrs:min:sec


#rm benchmark-arb-nucleus-decomp-gpu*.out benchmark-arb-nucleus-decomp-gpu*.err
module load StdEnv/2020 gcc/9.3.0 cuda/12.2 cmake/3.23.1 bazel/3.6.0 
cd benchmarks/KTruss

DATASETS=("cit-Patents.adj" "soc-LiveJournal1.adj" "wiki-Vote.adj")
DATADIR="../../../datasets"

for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started with KTruss ..."
    ./KTruss -s "${DATADIR}/${GRAPH}.adj"
    echo "Benchmarking graph $GRAPH with KTruss finished."
done

cd ../KCore/JulienneDBS17
for GRAPH in "${DATASETS[@]}"
do
    echo "Benchmarking graph $GRAPH started with KCore ..."
    ./KCore -s "${DATADIR}/${GRAPH}.adj"
    echo "Benchmarking graph $GRAPH with KCore finished."
done