
function argmax(f::Function, xs)
    i = indmax(map(f, xs))
    getindex(xs, i)
end
