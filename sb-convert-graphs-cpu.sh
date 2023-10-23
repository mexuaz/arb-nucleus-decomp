#!/bin/bash

#SBATCH --account=def-thomo
#SBATCH --job-name=convert-graph-adj
#SBATCH --output=convert-graph-adj.out
#SBATCH --error=convert-graph-adj.err
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4096M      # memory; default unit is megabytes
#SBATCH --ntasks-per-node=1 # Number of tasks per node
#SBATCH --time=00:20:00 # Time limit hrs:min:sec


# rm convert-graph-adj.out convert-graph-adj.err
module load StdEnv/2020 gcc/9.3.0 cmake/3.23.1 bazel/3.6.0 
cd utils

# If file ./snap_converter does not exist, then run make
[ -f ./snap_converter ] || make

# If file ./snap_converter does not exist, then exit script with error
[ -f ./snap_converter ] || { echo "Error: ./snap_converter does not exist."; exit 1; }

echo "Converting all graphs using ./snap_converter started ..."

DATASETS=("cit-Patents.txt" "soc-LiveJournal1.txt" "wiki-Vote.txt")
DATADIR="../../datasets"

for GRAPH in "${DATASETS[@]}"
do
    #echo "Downloading the graph ${GRAPH} from the SNAP collection ..."
    #wget "https://snap.stanford.edu/data/{$GRAPH}.gz" 
    
    #echo "Extracing graph $GRAPH ..."
    #gzip --decompress ${PWD}/$GRAPH.gz

    echo "Converting graph $GRAPH started with SNAP-to-adjacency-graph converter ..."
    # Runing with Bazel:
    ./snap_converter -- -s -i ${DATADIR}/$GRAPH -o "${DATADIR}/${GRAPH}.adj"
    echo "Converting graph $GRAPH finished."
done

echo "Converting all graphs using ./snap_converter finished."