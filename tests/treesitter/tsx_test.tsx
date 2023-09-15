function fn_1() {
  return <div />;
}

function fn_2(): void;

interface Iface_1 {}

class Cl_1 {
  meth_1() {}
  cl_fn_3 = () => {};
}

type Type1 = {};

const fn_3 = () => {};

const const_var = 'value';
let let_var = 'value';

describe("UnitTest", () => {
  afterAll(() => {});
  afterEach(() => {});
  beforeAll(() => {});
  beforeEach(() => {});
  test("should describe the test", () => {});
  it("is an alias for test", () => {});
  test.skip("skip this test", () => {});
  test.todo("this is a todo");
  describe.each([])("Test Suite", () => {
    test.each([])("runs multiple times", () => {});
  });
});

function* g() {}
const g_1 = function* () {};
