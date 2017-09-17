using CL
using Base.Test

for test in [#"counter",
             #"spvectors",
             "weight_dict",
             "math",
             "information_theory",
             "alphabet",
             "featureindex",
             "markov",
             "ngramlm",
             "similarity",
             "trees"]
    println("testing $test")
    include("test_$test.jl")
end
