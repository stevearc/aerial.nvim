class Cl_1 {
  meth_1() {}
}

function fn_1() {}

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
