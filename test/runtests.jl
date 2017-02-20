using CL
using Base.Test

for test in ["counter",
             "featureindex",
             "markov"]
    println("testing $test")
    include("test_$test.jl")
end
