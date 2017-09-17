
# argmax(c::Counter) = most_frequent(c)

# function argmax(v::SparseWeightVector)
#     length(v.w) == 0 && error("can't call most_frequent on a empty counter")
#     max_x, max_ct = nothing, 0
#     for (x, ct) in v.w
#         if ct > max_ct
#             max_x = x
#             max_ct = ct
#         end
#     end
#     max_x
# end

function argmax(f::Function, xs)
    i = indmax(map(f, xs))
    getindex(xs, i)
end
