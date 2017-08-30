module CL

export Counter,
    inc!, getcount, gettotal,
    most_frequent, n_most_frequent
export NestedCounter
export SparseWeightVector, spvec,
    set!, weight, total, magnitude

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

include("util/alphabet.jl")
include("util/counter.jl")
include("util/sparse_weight_vectors.jl")
include("util/math.jl")
include("util/information_theory.jl")
include("util/similarity_metrics.jl")
include("markov.jl")
include("lm/ngramlm.jl")
include("ml/featureindex.jl")
include("ml/hmm.jl")
include("grammar/phrase_structures.jl")

end # module
