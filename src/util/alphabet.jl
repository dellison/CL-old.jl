import Base: show, keys, values, start, next, done, length, getindex#, getindex!
import Base: ==, in

# Bijective mapping from strings to integers.
# based on TODO

type Alphabet{T}
    map::Dict{T,Int}
    list::Vector{T}
    i::Int
    isfrozen::Bool
    isgrowing::Bool
    # random_int::Int
end

Alphabet(t::DataType=String) = Alphabet(Dict{t,Int}(), t[], 1, false, true)

function Alphabet(task::Task)
    a = Alphabet()
    for x in task
        add(a, x)
    end
    return a
end

function Alphabet(l::AbstractArray)
    a = Alphabet()
    for x in l
        add(a, x)
    end
    return a
end

alphabet(a) = Alphabet(a)

show(io::IO,a::Alphabet) =
   print(io, "Alphabet(size=$(a.i-1),frozen=$(a.isfrozen))")

freeze!(a::Alphabet) = a.isfrozen = true
stop_growth!(a::Alphabet) = a.isgrowing = false

in(a::Alphabet, x) = in(a.map, x)
keys(a::Alphabet) = keys(a.map)
values(a::Alphabet) = values(a.map)
length(a::Alphabet) = length(a.map)
==(a::Alphabet) = ==(a.map)

start(a::Alphabet) = start(a.list)
next(a::Alphabet, state) = next(a.list, state)
done(a::Alphabet, state) = done(a.list, state)

function getindex(a::Alphabet, x)
    get(a.map, x) do
        a.isfrozen && error("Alphabet is frozen. Key '$x' not found.")
        !a.isgrowing && return nothing
        # TODO: random_int?
        j = a.map[x] = a.i
        a.i += 1
        push!(a.list, x)
        return j
    end
end

add(a::Alphabet, x) = getindex(a,x)

function add_many(a::Alphabet, xs)
    for x in xs
        add(a, x)
    end
end

lookup(a::Alphabet, i::Int) = a.list[i]
lookup_many(a::Alphabet, is) = [lookup(a,i) for i in is]
# lookup_many(a::Alphabet, is) = map(i->lookup(a,i), is)


plaintext(a::Alphabet) = join(a.list,"\n")
    
