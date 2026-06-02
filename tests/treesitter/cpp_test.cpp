void fn_1() {}

struct st_1 {};

struct {
} st_2;

namespace n_1 {
  struct st_n {};
}
using namespace n_1;  // This should not show up as a symbol

namespace n_2a {
  namespace n_2b {
    struct st_nn {};
  }
}
using n_2a::n_2b::st_nn;  // This should not show up as a symbol

namespace n_a::n_b::n_c {
  struct st_n {};
}

namespace n_abc = n_cba;

namespace {
  struct st_n {};
}

enum en_1 {};

class cl_1 {
  ~cl_1() {}

public:
  void meth_1() {}
};

void A::bar() {}

int *fn_2() {}

int **fn_3() {}

bool operator<(int, int) {}

void fn_4() {
  struct Point p1;                     // This should not show up as a symbol
  struct Point *p2 = new struct Point; // This should not show up as a symbol
}

int declaredFunction();

class A {
  int clsDeclaredFunction();
};
