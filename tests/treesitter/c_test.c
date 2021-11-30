#define FOO
#define BAR
void fn_1() FOO BAR {}

void *fn_2() FOO BAR { return 0; }

void fn_3() {}

void *fn_4() { return 0; }

void **fn_5() { return 0; }

typedef enum {
  kVal,
} kEnum;

typedef struct {
  int field;
} St_1;
