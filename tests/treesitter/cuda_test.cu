__global__ void fn_1() {}

struct st_1 {};

struct {
} st_2;

enum en_1 {};

class cl_1 {
  ~cl_1() {}

public:
  __device__ void meth_1() {}
};

__host__
void A::bar() {}
__host__ __device__ int *fn_2() {}

__device__ __host__
int **fn_3() {}
bool operator<(int, int) {}

void fn_4() {
  struct Point p1;                     // This should not show up as a symbol
  struct Point *p2 = new struct Point; // This should not show up as a symbol
  __shared__ struct Point *p3 = new struct Point; // This should not show up as a symbol
}
int declaredFunction();

class A {
  int clsDeclaredFunction();
};
