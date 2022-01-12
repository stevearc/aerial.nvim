mod mod_1 {
    enum Enum_1 {}

    fn Fn_1() {}

    struct MyStruct {}

    trait MyTrait {
        fn TraitFn();
    }

    impl MyStruct {
        fn StructFn() {}
    }

    impl Display for MyStruct {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "hi");
        }
    }
    impl<T> GenericTrait for MyStruct<T> {}
}
