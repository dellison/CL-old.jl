module CL

export Counter,
    inc!, getcount, gettotal, most_frequent

export train!

export MarkovModel,
    train!,
    generate

export NGramLM,
    bigram_lm,
    trigram_lm,
    train!,
    generate,
    generates

include("util/counter.jl")
include("util/similarity_metrics.jl")
include("markov.jl")
include("lm/ngramlm.jl")
include("ml/featureindex.jl")

end # module
