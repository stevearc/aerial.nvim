fn myFunc() bool {
    return true;
}

const MyStruct = struct {
    is_true: bool,
};

const MyTaggedUnion = union(enum) { choice1, choice2 };

test "my test" {
    myFunc();
}

test ident_test {
    myFunc();
}
