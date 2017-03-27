
magnitude(v::SparseVector) = sqrt(sum(v.nzval .^ 2))
magnitude(c::Counter) = sqrt(sum([x^2 for x in values(c)]))
