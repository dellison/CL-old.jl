"""
"""
type FeatureIndex{T}
    feature_map::Dict{T,Int}
    features::Vector{T}
    max::Int
    nextindex::Int

    # FeatureIndex(feature_map, features, max, nextindex) =
    #     new(feature_map, features, max, nextindex)
end

# function FeatureIndex(feature_map, features, max, nextindex)
#     FeatureIndex(feature_map, features, max, nextindex)
# end

function FeatureIndex(t::DataType = Any; max = 0)
    FeatureIndex(Dict{t,Int}(), t[], max, 1)
end

function FeatureIndex{T}(feats::AbstractVector{T}; max=0)
    if max == 0
        idx = FeatureIndex(T)
        idx.max = max
        for feat in feats
            index!(idx, feat)
        end
        return idx
    else
        c = Counter(feats)
        features, counts = sort([zip(c)...])[1:max]
        @show features
        return FeatureIndex(c.counts, features, max, 0)
    end
end

"""
"""
function feature(m::FeatureIndex, i::Int)
    try
        return m.features[i]
    catch BoundsError
        error("no feature at index $i")
    end
end

"""
"""
function index!(m::FeatureIndex, feature)
    get(m.feature_map, feature) do
        if m.nextindex == 0
            return 0
        else
            i = m.nextindex
            m.nextindex += 1
            push!(m.features, feature)
            return m.feature_map[feature] = i
        end
    end
end

"""
"""
function index(m::FeatureIndex, feature)
    get(m.feature_map, feature, m.nextindex)
end

# function makevector(idx::FeatureIndex, v::WeightVector)
#     a = zeros(idx.nextindex)
#     for (feature, weight) in v
#         a[getindex(idx, feature)] = weight
#     end
#     a        
# end

"""
"""
function onehot(idx::FeatureIndex, feature)
    if idx.max == 0
        a = zeros(Int, idx.nextindex)
    else
        a = zeros(Int, idx.max)
    end
    a[index(idx, feature)] = 1
    return a
end

import Base.sparsevec
function sparsevec(m::FeatureIndex, features::AbstractArray)
    sparsevec(Dict(CL.index(m, i)=>1 for i in features), m.nextindex)
end

function sparsevec(m::FeatureIndex, features::Dict)
    sparsevec(Dict(CL.index(m, feat) => val for (feat, val) in features), m.nextindex)
end
