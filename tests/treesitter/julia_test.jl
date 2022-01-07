module mod

const constant = nothing

function func()
end

myfunc() = nothing

abstract type MyType end

struct MyStruct <: MyType
    MyStruct() = new()
    method() = nothing
end

macro mac(expr)
end

end
