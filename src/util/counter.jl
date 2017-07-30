"""
    Counter

Counter is a Dictionary that maps its keys to integers and keeps track of the total.
"""
type Counter{T} <: Associative
    counts::Dict{T, Int}
    total::Int
    _cached::Bool

    Counter(d::Dict{T, Int}, total, cached) =
        new(d, total, cached)
end

Counter() = Counter{Any}(Dict{Any, Int}(), 0, false)

Counter(Typ::DataType) = Counter{Typ}(Dict{Typ, Int}(), 0, false)

# from a dictionary
Counter{T}(d::Dict{T, Int}) = Counter{T}(d, sum(values(d)), true)

# from a collection
function Counter{T}(a::AbstractArray{T})
    d = Dict{T, Int}()
    total = 0
    for x in a
        total += 1
        d[x] = get(d, x, 0) + 1
    end
    Counter{T}(d, total, true)
end


"""
Get the count of an item x in Counter c.
"""
getcount(c::Counter, x) = get(c.counts, x, 0)

"""
Get the total number of items in Counter c.
"""
function gettotal(c::Counter)
    if c._cached
        c.total
    else
        c._cached = true
        c.total = sum(values(c.counts))
    end
end

"""
Increment the count of item x in Counter c by i (default 1).
"""
function inc!(c::Counter, x, i::Int64 = 1)
    c._cached = false
    in(x, keys(c)) ? c.counts[x] += i : c.counts[x] = i
end

"""
    most_frequent(c::Counter)

Return the most common item in Conuter c.
"""
function most_frequent(c::Counter)
    length(c) == 0 && error("can't call most_frequent on a empty counter")
    max_x, max_ct = nothing, 0
    for (x, ct) in c
        if ct > max_ct
            max_x = x
            max_ct = ct
        end
    end
    max_x
end

"""
    n_most_frequent(c::Counter, n::Int)

Return a list of the most frequent n things in Counter c.
"""
function n_most_frequent{T}(c::Counter{T}, n::Int)
    return map(first, sort(collect(c), by=last, rev=true)[1:n])
end
##  iterating
import Base: start, next, done
start(c::Counter) = start(c.counts)
next(c::Counter, state) = next(c.counts, state)
done(c::Counter, state)  = done(c.counts, state)

##  using a Counter as a Dict
import Base: keys, values, get, setindex!, in, length
keys(c::Counter) = keys(c.counts)
values(c::Counter) = values(c.counts)
get(c::Counter, args...) = get(c.counts, args...)
setindex!(c::Counter, args...) = setindex!(c.counts, args)
in(x, c::Counter) = in(x, keys(c.counts))
length(c::Counter) = length(c.counts)
                       
##  merging one or more counters
import Base: merge
function merge(c::Counter, others...)
    Counter(merge(c.counts, [o.counts for o in others]...))
end

import Base: show
function show{T}(io::IO, x::Counter{T})
    t = gettotal(x)
    uniq = length(keys(x))
    if t == 0
        ct_repr = ""
    else
        ct_repr = "\n{\n"
        i = 0
        for (k, c) in x
            ct_repr = string(ct_repr, "  $k => $c,\n")
            i += 1
            if i > 5
                ct_repr = string(ct_repr, "  ...\n")
                break
            end
        end
        ct_repr = string(ct_repr, "}")
    end
    # print(io, "<Counter ($total total, $uniq unique)>$ct_repr")
    print(io, "Counter{$T} ($t total, $uniq unique)")
end

function sample(c::Counter)
    p = rand()
    total = gettotal(c)
    lst = nothing;
    for (n, w) in c.counts
        lst = n
        p -= w / total
        if p <= 0
            return n
        end
    end
    if lst === nothing
        error("couldn't sample from counter $c")
    else
        return lst
    end
end

"""
"""
type NestedCounter{Touter, Tinner}
    dict::Dict{Touter, Counter{Tinner}}
end

NestedCounter() = NestedCounter(Dict{Any, Counter{Any}}())
NestedCounter(t::DataType, t2::DataType=t) = NestedCounter(Dict{t, Counter{t2}}())

function getcount(nc::NestedCounter, outer, inner)
    if ! (outer in keys(nc.dict))
        return 0
    else
        return getcount(nc.dict[outer], inner)
    end
end

function getcount(nc::NestedCounter, outer)
    if ! (outer in keys(nc.dict))
        return 0
    else
        return gettotal(nc.dict[outer])
    end
end

function gettotal(nc::NestedCounter, outer)
    getcount(nc, outer)
end

function gettotal(nc::NestedCounter)
    sum([gettotal(ctr) for (k, ctr) in nc.dict])
end

function inc!{T1,T2}(nc::NestedCounter{T1,T2}, outer, inner, n=1)
    c = get!(()->Counter(T2), nc.dict, outer)
    inc!(c, inner, n)
end
