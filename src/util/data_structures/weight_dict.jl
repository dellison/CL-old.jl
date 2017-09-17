# this is meant to unify Counters and SparseWeightVectors

type WeightDict{K,V<:Number}
    weights::Dict{K,V}
    total::V
    _total_cached::Bool
    magnitude::Float64
    _magnitude_cached::Bool
end
typealias SparseWeightVector{K,V} WeightDict{K,V}

function WeightDict(K::Type=Any,V::Type=Float64)
    weights = Dict{K,V}()
    WeightDict{K,V}(weights, 0, false, 0, false)
end
typealias spvec WeightDict

# from a dict
function WeightDict{K,V<:Number}(d::Dict{K,V})
    WeightDict{K,V}(d, 0, false, 0, false)
end

# from a collection
function WeightDict{K}(a::AbstractArray{K})
    d = Dict{K, Int}()
    for x in a
        d[x] = get(d, x, 0) + 1
    end
    WeightDict{K,Int}(d, 0, false, 0, false)
end

weight(d::WeightDict, x) = get(d.weights, x, 0)

function total(d::WeightDict)
    d._total_cached && return d.total
    d._total_cached = true
    return d.total = sum(values(d.weights))
end

magnitude(d::WeightDict) = sqrt(sum(x^2 for x in values(d.weights)))

function inc!(d::WeightDict, x, i=1)
    d._total_cached = d._magnitude_cached = false
    in(x, keys(d.weights)) ? d.weights[x] += 1 : d.weights[x] = i
end

set!(d::WeightDict, x, v) = setindex!(d, v, x)

# treating a WeightDict just like a regular dict
import Base: keys, values, get, getindex, setindex!, in, length
keys(d::WeightDict) = keys(d.weights)
values(d::WeightDict) = values(d.weights)
get(d::WeightDict, args...) = get(d.weights, args...)
get(f::Function, d::WeightDict, x) = get(f, d.weights, x)
getindex(d::WeightDict, args...) = getindex(d.weights, args...)
function setindex!(d::WeightDict, args...)
    d._total_cached = d._magnitude_cached = false
    setindex!(d.weights, args...)
end
in(x, d::WeightDict) = in(x, keys(d.weights))
length(d::WeightDict) = length(d.weights)
function merge(d::WeightDict, others...)
    WeightDict(merge(d.weights, [o.weights for o in others]...))
end

# iterating
import Base: start, next, done
start(d::WeightDict) = start(d.weights)
next(d::WeightDict, state) = next(d.weights, state)
done(d::WeightDict, state)  = done(d.weights, state)


function argmax(d::WeightDict)
    length(d.weights) == 0 && error("can't call argmax on a empty counter")
    max_x, max_w = nothing, -Inf
    for (x, w) in d.weights
        if w > max_w
            max_x = x
            max_w = w
        end
    end
    max_x
end
# most_frequent = argmax
most_frequent(d::WeightDict) = argmax(d)

n_most_frequent(d::WeightDict, n::Int) =
    map(first, sort(collect(d), by=last, rev=true)[1:n])

# TODO: probability
# sampling



type NestedWeightDict{K1,K2,V}
    weights::Dict{K1,WeightDict{K2,V}}
end

function NestedWeightDict(K1=Any,K2=Any,V=Float64)
    w = Dict{K1,WeightDict{K2,V}}()
    NestedWeightDict{K1,K2,V}(w)
end

# treating a NestedWeightDict just like a regular dict
keys(d::NestedWeightDict) = keys(d.weights)
values(d::NestedWeightDict) = values(d.weights)
get(d::NestedWeightDict, args...) = get(d.weights, args...)
get(f::Function, d::NestedWeightDict, x) = get(f, d.weights, x)
getindex(d::NestedWeightDict, arg) = getindex(d.weights, arg)
function setindex!(d::NestedWeightDict, args...)
    # d._total_cached = d._magnitude_cached = false
    setindex!(d.weights, args...)
end
in(x, d::NestedWeightDict) = in(x, keys(d.weights))
length(d::NestedWeightDict) = length(d.weights)

# iterating
start(d::NestedWeightDict) = start(d.weights)
next(d::NestedWeightDict, state) = next(d.weights, state)
done(d::NestedWeightDict, state)  = done(d.weights, state)

function weight(d::NestedWeightDict, x1, x2)
    !(x1 in keys(d.weights)) ? 0 : weight(d.weights[x1], x2)
end

function weight(d::NestedWeightDict, x1)
    !(x1 in keys(d.weights)) ? 0 : total(d.weights[x1])
end

function total(d::NestedWeightDict)
    sum([total(d2) for (w, d2) in d.weights])
end

function inc!{K1,K2,V}(d::NestedWeightDict{K1,K2,V}, x1, x2, n=1)
    w = get!(()->Counter(K2), d.weights, x1)
    inc!(w, x2, n)
end

# function set!(d::NestedWeightDict, x1, x2, v)
#     d = get!(d.weights, x1)
#     d[x2] = v
# end

# "Counter" types as a special case
typealias Counter{K} WeightDict{K,Int}
Counter(K::Type=Any) = WeightDict(K,Int)
Counter(d::Dict) = WeightDict(d)
Counter(a::AbstractArray) = WeightDict(a)
c(c::Counter, x) = weight(c, x)

typealias NestedCounter{K1,K2} NestedWeightDict{K1,K2,Int}
NestedCounter(K1::Type=Any,K2::Type=Any) = NestedWeightDict(K1,K2,Int)
c(c::NestedCounter, xs...) = weight(c, xs...)
