using CL
using Base.Test

for test in ["counter",
             "featureindex",
             "markov",
             "ngramlm"]
    println("testing $test")
    include("test_$test.jl")
end
