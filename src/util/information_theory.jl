"""
    entropy(c::Counter)

Entropy of a Counter, as a discrete probability distribution.
"""
function entropy(c::Counter)
    ent, t = 0.0, total(c)
    for (x, count) in c
        p = count / t
        ent -= p * log2(p)
    end
    return ent
end                 

"""
    entropy(v::SparseWeightVector)

Entropy of a sparse weight vector.
"""
function entropy(v::SparseWeightVector)
    ent, total = 0.0, total(v)
    for (x, c) in v.dict
        p = count / total
        ent -= p * log2(p)
    end
    return ent
end

"""
    entropy(m::NestedCounter)

Entropy of the distribution of "outer" values.
"""
function entropy(m::NestedCounter)
    ent, total = 0.0, total(m)
    for (x, c) in m.dict
        p = gettotal(c) / total
        ent -= p * log2(p)
    end
    return ent
end

"""
    entropy(m::NestedCounter, x)

Entropy of the distribution of "outer" values.
"""
entropy(m::NestedCounter, x) = entropy(m.dict[x])
