void fn_1() {}

struct st_1 {};

struct {
} st_2;

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
