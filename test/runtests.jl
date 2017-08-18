using CL
using Base.Test

for test in ["counter",
             "spvectors",
             "math",
             "information_theory",
             "featureindex",
             "markov",
             "ngramlm",
             "similarity"]
    println("testing $test")
    include("test_$test.jl")
end
