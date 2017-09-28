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
    entropy(m::NestedWeightDict)

Entropy of the distribution of "outer" values.
"""
function entropy(m::NestedWeightDict)
    ent, tot = 0.0, total(m)
    for (x, c) in m
        p = total(c) / tot
        ent -= p * log2(p)
    end
    return ent
end

"""
    entropy(m::NestedWeightDict, x)

Entropy of the distribution of "outer" values.
"""
entropy(m::NestedWeightDict, x) = entropy(m.weights[x])
