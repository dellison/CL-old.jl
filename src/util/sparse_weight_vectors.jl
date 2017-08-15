abstract WeightVector

type SparseWeightVector{Tkey,Tval<:Number} <: WeightVector
    w::Dict{Tkey,Tval}
end

function SparseWeightVector(Tkey=Any,Tval=Float64)
    SparseWeightVector(Dict{Tkey,Tval}())
end

spvec(keytype=Any,valtype=Float64) = SparseWeightVector(keytype,valtype)


inc!(v::SparseWeightVector, x, i=1) =
    in(x, keys(v.w)) ? v.w[x] += i : v.w[x] = i

set!(v::SparseWeightVector, x, n) = v.w[x] = n

weight{V,T}(v::SparseWeightVector{V,T}, x) = get(()->zero(T), v.w, x)
total(v::SparseWeightVector) = sum(values(v.w))
import Base.sum
sum(v::SparseWeightVector) = sum(values(v.w))
magnitude(v::SparseWeightVector) = sqrt(sum(x^2 for x in values(v.w)))

immutable ISparseWeightVector{Tkey,Tval<:Number} <: WeightVector
    w::Dict{Tkey,Tval}
    total::Tval
    magnitude::Tval
end

ISparseWeightVector(v::SparseWeightVector) =
    ISparseWeightVector(v.w, gettotal(v), magnitude(v))

ispvec(v::SparseWeightVector) = ISparseWeightVector(v)
sum(v::ISparseWeightVector) = v.total
total(v::ISparseWeightVector) = v.total
magnitude(v::ISparseWeightVector) = v.magnitude
