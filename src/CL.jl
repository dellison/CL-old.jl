module CL

export Counter,
    inc!, getcount, gettotal, most_frequent

export train!

export MarkovModel,
    train!,
    generate

include("util/counter.jl")
include("markov.jl")
include("ml/featureindex.jl")

end # module
