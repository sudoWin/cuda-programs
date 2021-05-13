#include <cuda.h>
#include <stdio.h>
#include <iostream>
#include <chrono>
using namespace std;

__global__ void add(int *a, int *b)
{
    for(int i = 0; i < 1000000; i++)
        a[i] += b[i];
}
void addCPU(int *a, int *b)
{
    for(int i = 0; i < 1000000; i++)
        a[i] += b[i];
}
int main()
{
    std::chrono::_V2::system_clock::time_point checkpoint[10];
    int n = 1000000;
    int *a = (int *)malloc(n * sizeof(int));
    int *b = (int *)malloc(n * sizeof(int));
    int *da, *db;

    srand(time(NULL));
    for(int i = 0; i < n; i++)
    {
        a[i] = rand() % 152;
        b[i] = rand() % 314;
    }

    cudaMalloc(&da, sizeof(int) * n);
    cudaMalloc(&db, sizeof(int) * n);
    cudaMemcpy(da, a, sizeof(int) * n, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, sizeof(int) * n, cudaMemcpyHostToDevice);

    checkpoint[0] = std::chrono::high_resolution_clock::now();
    add<<<1,1>>>(da, db);
    cudaDeviceSynchronize();
    checkpoint[1] = std::chrono::high_resolution_clock::now();
    addCPU(a, b);
    checkpoint[2] = std::chrono::high_resolution_clock::now();

    auto x = std::chrono::duration_cast<std::chrono::microseconds>(checkpoint[1] - checkpoint[0]).count();
    auto y = std::chrono::duration_cast<std::chrono::microseconds>(checkpoint[2] - checkpoint[1]).count();

    cout << "Your single CPU thread is "<<((float)x)/y<<" times faster than your single GPU thread."<< endl;
    return 0;
}

