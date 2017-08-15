using CL
using Base.Test

for test in ["counter",
             "spvectors",
             "featureindex",
             "markov",
             "ngramlm",
             "similarity"]
    println("testing $test")
    include("test_$test.jl")
end
