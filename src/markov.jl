# const MARKOV_START = "<START>"
# const MARKOV_END = "<END>"

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

next_state(state::MarkovState, x) =
    get!(state.transitions, x, (MarkovState(), 0))

function next_states(m::MarkovState)
    return keys(m.transitions)
end

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
    _, weight = get(state.transitions, x, (0, zero(N)))
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
    start_sym::String
    end_sym::String

    function MarkovModel(n::N; start_sym = "-START-", end_sym = "-END-")
        new(n, Dict{T, MarkovState{T, N}}(), start_sym, end_sym)
    end
end

function MarkovModel(n, t::DataType = Any)
    MarkovModel{t, Int}(n)
end

import Base.show
show(io::IO, m::MarkovModel) = print(io, "MarkovModel<$(m.order)>")


# function state{T,N}(m::MarkovModel{T,N}, symbols::Vector{T})
function state(m::MarkovModel, symbols::AbstractVector)
    # @show symbols
    s = state(m, first(symbols))
    # @show s
    for symbol in symbols
        # @show symbol
        s, _ = next(s, symbol)
        # @show s
    end
    s
end

function state{T,N}(m::MarkovModel{T,N}, symbol::T)
    # @show symbol
    get!(()->MarkovState{T,N}(), m.states, symbol)
end

function state{T,N}(m::MarkovModel{T,N})
    state(m, [m.start_sym for i=1:m.order])
end

function pad(m::MarkovModel, seq::AbstractVector)
    [[m.start_sym for _=1:m.order] ; seq ; [m.end_sym for _=1:m.order]]
end

function pad(m::MarkovModel, seq::Tuple)
    [[m.start_sym for _=1:m.order] ; [seq...] ; [m.end_sym for _=1:m.order]]
end

function train!(m::MarkovModel, seq)
    s = pad(m, seq)
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
        push!(seq, m.start_sym)
    end
    while seq[end] != m.end_sym
        push!(seq, sample(state(m, seq[end-m.order+1:end])))
    end
    filter(x -> x != m.start_sym && x != m.end_sym, seq)
end

function p_symbol_cond{T,N}(m::MarkovModel{T,N}, history::T, symbol)
    p_symbol_cond(m, [history], symbol)
end

function p_symbol_cond(m::MarkovModel, history::AbstractVector, symbol)
    st = state(m, history)
    w = weight(st, symbol)
    return w / st.total
end

