using CL
using Base.Test

for test in ["counter",
             "featureindex",
             "markov",
             "ngramlm",
             "similarity"]
    println("testing $test")
    include("test_$test.jl")
end
