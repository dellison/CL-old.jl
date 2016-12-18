using CL
using Base.Test

for test in ["counter"]
    println("testing $test")
    include("test_$test.jl")
end
