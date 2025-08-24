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

int var = 5;

int foo() {
  return 0;
}

int bar() {
  return 0;
}

// K&R style
int fn_kr(bar, baz, qux)
int bar, baz;
char *qux;
{
}

// specifiers after types
int static inline fn_specifiers(int arg1) {
  return 5;
}

// fn definition with macro attributes
void * fn_macro_attributes(int arg1)
  SOME_ATTR
  SOME_ATTR(1)
{
  return 5;
}
