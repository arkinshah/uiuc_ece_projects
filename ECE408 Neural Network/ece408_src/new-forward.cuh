
#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#include <mxnet/base.h>



namespace mxnet
{
namespace op
{

__global__ void forward_kernel(float *y, const float *x, const float *k, const int B, const int M, const int C, const int H, const int W, const int K)
{

    /*
    Modify this function to implement the forward pass described in Chapter 16.
    We have added an additional dimension to the tensors to support an entire mini-batch
    The goal here is to be correct AND fast.
    We have some nice #defs for you below to simplify indexing. Feel free to use them, or create your own.
    */
#define BLOCK_WIDTH 16
    const int H_out = H - K + 1;
    const int W_out = W - K + 1;

    // An example use of these macros:
    // float a = y4d(0,0,0,0)
    // y4d(0,0,0,0) = a
#define y4d(i3, i2, i1, i0) y[(i3) * (M * H_out * W_out) + (i2) * (H_out * W_out) + (i1) * (W_out) + i0]
#define x4d(i3, i2, i1, i0) x[(i3) * (C * H * W) + (i2) * (H * W) + (i1) * (W) + i0]
#define k4d(i3, i2, i1, i0) k[(i3) * (C * K * K) + (i2) * (K * K) + (i1) * (K) + i0]

    int W_lin = ceil( (float) (W-K + 1) / BLOCK_WIDTH );

    int b, m, h, w, c, i, j;
    b = blockIdx.x;
    m = blockIdx.y;
    h = blockIdx.z / W_lin * BLOCK_WIDTH + threadIdx.y;
    w = blockIdx.z % W_lin * BLOCK_WIDTH + threadIdx.x;

    /* bound checking*/
    if (h < H_out && w < W_out){
            float output = 0;
            for (c = 0; c < C; c++){
                    for (i = 0; i < K; i++){               // loop over
                            for (j = 0; j < K; j++){       // K * K filter
                                    output += x4d(b, c, h+i, w +j) * k4d(m, c, i, j);
                            }
                    }
            }
            y4d(b, m, h, w) = output;
    }

#undef y4d
#undef x4d
#undef k4d
}

/* 
   This function is called by new-inl.h
   Any code you write should be executed by this function.
   For ECE408, we only expect the float version of the operator to be called, so here we specialize with only floats.
*/
template <>
void forward<gpu, float>(mshadow::Tensor<gpu, 4, float> &y, const mshadow::Tensor<gpu, 4, float> &x, const mshadow::Tensor<gpu, 4, float> &w)
{
#define BLOCK_WIDTH 16
    // Use mxnet's CHECK_EQ to do assertions.
    // Remove this assertion when you do your implementation!
    //CHECK_EQ(0, 1) << "Remove this line and replace with your implementation";

    // Extract the tensor dimensions into B,M,C,H,W,K
    int B = x.shape_[0];
    int M = y.shape_[1];
    int C = x.shape_[1];
    int H = x.shape_[2];
    int W = x.shape_[3];
    int K = w.shape_[3];

    int W_lin = ceil( (float) (W-K + 1) / BLOCK_WIDTH );
    int H_lin = ceil( (float) (H-K + 1) / BLOCK_WIDTH );
    int gridZ = W_lin * H_lin;

    // Set the kernel dimensions
    dim3 gridDim(B, M, gridZ);
    dim3 blockDim(BLOCK_WIDTH, BLOCK_WIDTH, 1);

    // Call the kernel
    forward_kernel<<<gridDim, blockDim>>>(y.dptr_,x.dptr_,w.dptr_, B,M,C,H,W,K);

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
    CHECK_EQ(0,1) << "Remove this line and replace it with your implementation.";
}
}
}

#endif
