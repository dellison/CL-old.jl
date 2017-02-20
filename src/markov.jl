const MARKOV_START = "<START>"
const MARKOV_END = "<END>"

type MarkovState{T, N<:Number}
    transitions::Dict{T, Tuple{T,N}}
    total::N

    function MarkovState()
        new(Dict{T, Tuple{T,N}}(), 0)
    end    
end

MarkovState() = MarkovState{Any, Int}()

next(state::MarkovState, x) =
    get!(state.transitions, x, (MarkovState(), 0))

function inc!(state::MarkovState, x, weight=1)
    state.total += weight
    n, w = next(state, x)
    b = w + weight
    state.transitions[x] = (n, b)
    n, b
end
    
function set!(state::MarkovState, x, n)
    state.total = state.total + n
    nx, w = next(state, x)
    state.transitions[x] = (nx, w + n)
    n
end

function weight{T,N}(state::MarkovState{T,N}, x)
    _, weight = get(state.transitions, x, zero(N))
    weight
end

function sample(state::MarkovState)
    p = rand()
    last;
    for (s, (st, w)) in state.transitions
        last = s
        p -= w / state.total
        if p <= 0
            return s
        end
    end
    last
end

type MarkovModel{T, N}
    order::Int
    states::Dict{T, MarkovState{T}}

    function MarkovModel(n::N)
        new(n, Dict{T, MarkovState{T, N}}())
    end
end

function MarkovModel(n, t::DataType = Any)
    MarkovModel{t, Int}(n)
end

import Base.show
show(io::IO, m::MarkovModel) = print(io, "MarkovModel<$(m.order)>")

state{T,N}(m::MarkovModel{T,N}, symbol::T) =
    get!(()->MarkovState{T,N}(), m.states, symbol)

function state{T,N}(m::MarkovModel{T,N}, symbols::Vector{T})
    s = state(m, first(symbols))
    for symbol in symbols
        s, _ = next(s, symbol)
    end
    s
end

function train!(m::MarkovModel, seq)
    s = [[MARKOV_START for _=1:m.order] ; seq ; [MARKOV_END for _=1:m.order]]
    for i = 1:length(s) - m.order
        gram = s[i:i+m.order]
        next = state(m, first(gram))
        for symbol in gram
            next, w = inc!(next, symbol)
        end
    end
    nothing
end

function generate{T,N}(m::MarkovModel{T,N}, length = 0)
    seq = Any[]
    for i = 1:m.order
        push!(seq, MARKOV_START)
    end
    while seq[end] != MARKOV_END
        push!(seq, sample(state(m, seq[end-m.order+1:end])))
    end
    filter(x -> x != MARKOV_START && x != MARKOV_END, seq)
end
