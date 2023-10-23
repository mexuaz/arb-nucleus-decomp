#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=build-arb-nucleus-decomp-gpu
#SBATCH --output=build-arb-nucleus-decomp-gpu.out
#SBATCH --error=build-arb-nucleus-decomp-gpu.err
#SBATCH --nodes=1 # Number of nodes
#SBATCH --gres=cpu:32 # Number of CPUs (Mac cores on Cascade Lake with GPU)
#SBATCH --gres=gpu:1 # Number of GPUs (per node)
#SBATCH --mem=192000M # Memory per node (Max memory on Cascade Lake with GPU 187G)
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=10:00:00 # Time limit hrs:min:sec
#SBATCH --constraint=cascade # define specific Node


#rm build-arb-nucleus-decomp-gpu.out build-arb-nucleus-decomp-gpu.err
module load StdEnv/2020 gcc/9.3.0 cuda/12.2 cmake/3.23.1 bazel/3.6.0 
cd benchmarks/NucleusDecomposition

echo "Build started ..."
bazel build :NucleusDecomposition_main
echo "Build finished."