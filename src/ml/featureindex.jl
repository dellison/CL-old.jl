"""
"""
type FeatureIndex{T}
    feature_map::Dict{T,Int}
    features::Vector{T}
    nextindex::Int
end

function FeatureIndex(t::DataType = Any)
    FeatureIndex(Dict{t,Int}(), t[], 1)
end

function FeatureIndex{T}(feats::AbstractVector{T})
    idx = FeatureIndex(T)
    for feat in feats
        index!(idx, feat)
    end
    idx
end

"""
"""
function feature(m::FeatureIndex, i::Int)
    try
        m.features[i]
    catch BoundsError
        error("no feature at index $i"P)
    end
end

"""
"""
function index!(m::FeatureIndex, feature)
    get(m.feature_map, feature) do
        i = m.nextindex
        m.nextindex += 1
        push!(m.features, feature)
        m.feature_map[feature] = i
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
    a = zeros(Int, idx.nextindex)
    a[index(idx, feature)] = 1
    a
end

import Base.sparsevec
function sparsevec(m::FeatureIndex, features::AbstractArray)
    sparsevec(Dict(CL.index(m, i)=>1 for i in features), m.nextindex)
end

function sparsevec(m::FeatureIndex, features::Dict)
    sparsevec(Dict(CL.index(m, feat) => val for (feat, val) in features), m.nextindex)
end
