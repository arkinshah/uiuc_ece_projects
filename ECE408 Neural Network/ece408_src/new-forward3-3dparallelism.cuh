#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#define BLOCK_SIZE 1024
#define TILE_WIDTH 24 // idk why 24 works better than 16 & 32, used trial and error between these 3 numbers

#include <mxnet/base.h>

namespace mxnet
{
namespace op
{

__global__ void matrixMultiply(float* X, float* Y, float* kernel, int numAColumns, int numCColumns, int x_ind, int y_ind, int M, int H, int W, int K)
{
  //forked and modified from MP3 (kevinl8)
  //@@ Insert code to implement matrix multiplication here
  //@@ You have to use shared memory for this MP
  int tx = threadIdx.x;
  int ty = threadIdx.y;
  //int tz = threadIdx.z;
  int bx = blockIdx.x;
  int by = blockIdx.y;
  int bz = blockIdx.z;

  int a, b, c, q, w, h;

  int Row = by * TILE_WIDTH + ty;
  int Col = bx * TILE_WIDTH + tx;
  float cValue = 0;

  __shared__ float Ads[TILE_WIDTH][TILE_WIDTH];
  __shared__ float Bds[TILE_WIDTH][TILE_WIDTH];

  X = X + (bz * x_ind);
  Y = Y + (bz * y_ind);

  for (int i = 0; i < ceil((float) numAColumns / TILE_WIDTH); i++)
  {

    if (((i * TILE_WIDTH + tx) < numAColumns) && (Row < M))
    {
      Ads[ty][tx] = kernel[(i * TILE_WIDTH + tx) + (numAColumns * Row)];
    }
    else
    {
      Ads[ty][tx] = 0;
    }

    c = (i * TILE_WIDTH + ty);
    if ((c < numAColumns) && (Col < numCColumns))
    {
      h = Col / (W - K + 1);
      w = Col % (W - K + 1);
      q = c % K;
      c = c / K;
      a = c % K;
      b = c / K;
      Bds[ty][tx] = X[(w + q) + ((h + a) * (W)) + (W * H * b)];
    }
    else
    {
      Bds[ty][tx] = 0;
    }

    __syncthreads();

    for (int k = 0; k < TILE_WIDTH; k++)
    {
      cValue += Bds[k][tx] * Ads[ty][k];
    }

    __syncthreads();
  }

  if ((Row < M) && (Col < numCColumns))
  {
    Y[(Row * numCColumns) + Col] = cValue;
  }
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

  int H_unroll = H_out * W_out;
  int w_base = C * K * K;
  int x_ind = C * H * W;
  int y_ind = M * H_unroll;

  float *X = x.dptr_;
  float *Y = y.dptr_;
  float *_K = k.dptr_;

  dim3 gridDim(ceil((float)H_unroll / TILE_WIDTH), ceil((float)M / TILE_WIDTH), B);
  dim3 blockDim(TILE_WIDTH, TILE_WIDTH, 1);

  matrixMultiply<<<gridDim, blockDim>>>(X, Y, _K, w_base, H_unroll, x_ind, y_ind, M, H, W, K);
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