#include "a3.hpp"
#include <vector>
#include <cmath>
#include <functional>
#include <cuda_runtime.h>
#include <algorithm>
#include <iostream>

__global__ void computeKDE(int n, float h, const float* x, float* y) {
    extern __shared__ float sharedX[]; // Shared memory for 'x' values
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int tx = threadIdx.x;

    if (i < n) {
        // Load 'x' values into shared memory
        sharedX[tx] = x[i];
        __syncthreads(); // Synchronize to make sure all 'x' are loaded

        float sum = 0.0;
        float inv_h = 1.0 / h;
        for (int j = 0; j < n; j++) {
            float u = (sharedX[tx] - x[j]) * inv_h;
            sum += exp(-0.5 * u * u) / (sqrtf(2 * M_PI));
        }
        y[i] = sum / (n * h);
    }
}


void gaussian_kde(int n, float h, const std::vector<float>& x, std::vector<float>& y) {
    float *d_x, *d_y;

    cudaMalloc(&d_x, n * sizeof(float));
    cudaMalloc(&d_y, n * sizeof(float));

    cudaMemcpy(d_x, x.data(), n * sizeof(float), cudaMemcpyHostToDevice);

    // int threadsPerBlock = 256;
    // int blocks = (n + threadsPerBlock - 1) / threadsPerBlock;

    int threadsPerBlock = 256;
    int blocks = (n + threadsPerBlock - 1) / threadsPerBlock;
    int sharedMemSize = threadsPerBlock * sizeof(float);

    computeKDE<<<blocks, threadsPerBlock, sharedMemSize>>>(n, h, d_x, d_y);

    // computeKDE<<<blocks, threadsPerBlock>>>(n, h, d_x, d_y);
    // cudaDeviceSynchronize();
    cudaDeviceSynchronize();
cudaError_t error = cudaGetLastError();
if (error != cudaSuccess) {
    // std::cerr << "CUDA Error: " << cudaGetErrorString(error) << std::endl;
    // Handle error or exit
    fprintf(stderr, "CUDA Error: %s\n", cudaGetErrorString(error));
}

    cudaMemcpy(y.data(), d_y, n * sizeof(float), cudaMemcpyDeviceToHost);

    cudaFree(d_x);
    cudaFree(d_y);
}
