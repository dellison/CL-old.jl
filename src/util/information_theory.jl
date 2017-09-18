"""
    entropy(d::WeightDict)

Entropy of a WeightDict, treated as a probability distribution.
"""
function entropy(d::WeightDict)
    ent, t = 0.0, total(d)
    for (x, count) in d
        p = count / t
        ent -= p * log2(p)
    end
    return ent
end

"""
    entropy(m::NestedCounter)

Entropy of the distribution of "outer" values.
"""
function entropy(m::NestedWeightDict)
# function entropy(m::NestedCounter)
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
entropy(m::NestedWeightDict, x) = entropy(m.dict[x])
