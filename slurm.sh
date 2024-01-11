#!/bin/bash

#SBATCH --job-name="GPGPU-Benchmark-A100"
#SBATCH --output=%j.stdout
#SBATCH --error=%j.stderr
#SBATCH --nodes=1
#SBATCH --time=02:00:00
#SBATCH --mem=160000
#SBATCH --cluster=ub-hpc
#SBATCH --qos=general-compute
#SBATCH --partition=general-compute
#SBATCH --gres=gpu:1
#SBATCH --reservation=ubhpc-future
#SBATCH --constraint=A100
#SBATCH --gres-flags=disable-binding

# Load the CUDA module
module load cuda
echo "Running on Node: "
hostname

# Suggested input sizes
INPUT_SIZES="10000 50000 100000 500000 1000000"

#echo "Test with 33"
#srun ./a3 33 0.1
#echo "Benchmarking GPGPU Code on A100 GPU"
for N in $INPUT_SIZES
do
    echo "Input Size: $N"
    srun ./a3 $N 0.1
done

# Benchmarking on Intel CPU
echo "Benchmarking on Intel CPU"
for N in $INPUT_SIZES
do
    echo "Input Size: $N"
    srun --constraint=AVX512 ./a3_cpu $N $N
done

# Benchmarking on AMD CPU
#echo "Benchmarking on AMD CPU"
#for N in $INPUT_SIZES
#do
#    echo "Input Size: $N"
#    srun --constraint=AMD ./a3_cpu $N $N
#done

