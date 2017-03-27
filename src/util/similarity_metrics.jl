
magnitude(v::SparseVector) = sqrt(sum(v.nzval .^ 2))
magnitude(c::Counter) = sqrt(sum([x^2 for x in values(c)]))

# cosine similarity
cosine(v1, v2) = dot(v1, v2) / (magnitude(v1) * magnitude(v2))
