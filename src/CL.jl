module CL

export WeightDict, weight, total, inc!, set!,
    most_frequent, n_most_frequent

export Counter, c, total,
    NestedCounter

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

include("util/data_structures/trees.jl")
include("util/data_structures/weight_dict.jl")
include("util/alphabet.jl")
include("util/math.jl")
include("util/information_theory.jl")
include("util/similarity_metrics.jl")
include("markov.jl")
include("lm/ngramlm.jl")
include("ml/featureindex.jl")
include("ml/hmm.jl")

end # module
