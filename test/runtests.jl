using CL
using Base.Test

for test in ["counter",
             "spvectors",
             "math",
             "information_theory",
             "alphabet",
             "featureindex",
             "markov",
             "ngramlm",
             "similarity",
             "phrase_structure"]
    println("testing $test")
    include("test_$test.jl")
end
