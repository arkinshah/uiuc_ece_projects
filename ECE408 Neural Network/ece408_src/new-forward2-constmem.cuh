#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#include <mxnet/base.h>

#define BLOCK_SIZE 1024
#define TILE_WIDTH 16
#define KERNEL 10000

namespace mxnet
{
namespace op
{

__constant__ float const_kernel[KERNEL];

__global__ void matrixMultiply(float *B, float *C, int numAColumns, int numCRows, int numCColumns)
{
    //forked and modified from MP3 (kevinl8)
    //second modification made to new-forward1.cuh
    //@@ Insert code to implement matrix multiplication here
    //@@ You have to use shared memory for this MP
    __shared__ float Bds[TILE_WIDTH][TILE_WIDTH];

    int bx = blockIdx.x;
    int by = blockIdx.y;
    int dx = blockDim.x;
    int dy = blockDim.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int Row = by * dy + ty;
    int Col = bx * dx + tx;

    float cValue = 0;

    for (int i = 0; i < ceil((float)numAColumns / TILE_WIDTH); i++)
    {

        if ((i * TILE_WIDTH + ty) < numAColumns)
        {
            Bds[ty][tx] = B[(i * TILE_WIDTH + ty) * numCColumns + Col];
        }
        else
        {
            Bds[ty][tx] = 0;
        }
        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; k++)
        {
            if ((i * TILE_WIDTH + k) < numAColumns)
            {
                cValue += Bds[k][tx] * const_kernel[Row * numAColumns + i * TILE_WIDTH + k];
            }
        }
        __syncthreads();
    }

    if ((Row < numCRows) && (Col < numCColumns))
    {
        C[Row * numCColumns + Col] = cValue;
    }
}

void gemm(int w_base, int M, int H_unroll, float *Y, float *X_unroll)
{
    dim3 gridDim(ceil((float)H_unroll / TILE_WIDTH), ceil((float)M / TILE_WIDTH));
    dim3 blockDim(TILE_WIDTH, TILE_WIDTH);
    matrixMultiply<<<gridDim, blockDim>>>(X_unroll, Y, w_base, M, H_unroll);
}

__global__ void unroll_Kernel(int C, int H, int W, int K, float *X, float *X_unroll, int size)
{
    //unroll_kernel based on chapter 16;
    int t = blockDim.x * blockIdx.x + threadIdx.x;

    int H_out = H - K + 1;
    int W_out = W - K + 1;
    int W_unroll = H_out * W_out;

    if (t < size)
    {
        int c = t / W_unroll;
        int s = t % W_unroll;
        int q = c % K;
        c = c / K;
        int a = c % K;
        int b = c / K;
        int w_out = s % W_out;
        int h_out = s / W_out;
        X_unroll[t] = X[(b) * (H * W) + (h_out + a) * (W) + w_out + q];
    }
}

void unroll_gpu(int C, int H, int W, int K, float *X, float *X_unroll, int size)
{
    int num_blocks = ceil((float)size / BLOCK_SIZE);
    unroll_Kernel<<<num_blocks, BLOCK_SIZE>>>(C, H, W, K, X, X_unroll, size);
}

/* 
   This function is called by new-inl.h
   Any code you write should be executed by this function.
   For ECE408, we only expect the float version of the operator to be called, so here we specialize with only floats.
*/
template <>
void forward<gpu, float>(mshadow::Tensor<gpu, 4, float> &y, const mshadow::Tensor<gpu, 4, float> &x, const mshadow::Tensor<gpu, 4, float> &k)
{

    // Extract the tensor dimensions into B,M,C,H,W,K
    // ...
    const int B = x.shape_[0];
    const int M = y.shape_[1];
    const int C = x.shape_[1];
    const int H = x.shape_[2];
    const int W = x.shape_[3];
    const int K = k.shape_[3];

    const int H_out = H - K + 1;
    const int W_out = W - K + 1;
    float* Y = y.dptr_;
    float* X = x.dptr_;
    float* _K = k.dptr_;
    cudaMemcpyToSymbol(const_kernel, _K, sizeof(float) * M * C * K * K);


    float *X_unroll;
    int w_base = C * K * K;
    int H_unroll = H_out * W_out;
    int size = w_base * H_unroll;
    cudaMalloc(&X_unroll, sizeof(float) * size);

    for (int i = 0; i <= B; i++)
    {
        unroll_gpu(C, H, W, K, X + i * (C * H * W), X_unroll, size);
        gemm(w_base, M, H_unroll, Y + i * (M * H_unroll), X_unroll);
    }
    cudaFree(X_unroll);

    // Use MSHADOW_CUDA_CALL to check for CUDA runtime errors.
    MSHADOW_CUDA_CALL(cudaDeviceSynchronize());
}

/* 
    This tells mxnet how to do an op when it's not a float.
    This is not used in the ECE408 project
*/
template <typename gpu, typename DType>
void forward(mshadow::Tensor<gpu, 4, DType> &y, const mshadow::Tensor<gpu, 4, DType> &x, const mshadow::Tensor<gpu, 4, DType> &w)
{
    CHECK_EQ(0, 1) << "Remove this line and replace it with your implementation.";
}
} // namespace op
} // namespace mxnet

#endif
