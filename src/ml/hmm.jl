
type HMM{Tsymbol,Tstate}
    # symbol_counts::Counter{Tsymbol}
    symbol_state_counts::NestedCounter{Tsymbol, Tstate}
    state_model::MarkovModel{Tstate, Int}
end

function HMM(order::Int, t::DataType=Any)
    # symbol_counts = Counter(t)
    symbol_state_counts = NestedCounter(t, t)
    state_model = MarkovModel(order, t)
    HMM(symbol_state_counts, state_model)
end

function train!(m::HMM, sequence)
    symbols, states = zip(sequence...)
    train!(m.state_model, states)
    for (symbol, state) in sequence
        # inc!(m.symbol_counts, symbol)
        inc!(m.symbol_state_counts, symbol, state)
    end
end

function forward_backward(m::HMM, sequence)
end

immutable ViterbiCell
    prob::Float64
    prev
end

type ViterbiTrellis
    V::Vector{Dict{String, ViterbiCell}}
end

viterbi_trellis(len::Int) =
    ViterbiTrellis([Dict{String, ViterbiCell}() for i in 1:len])

function decode(v::ViterbiTrellis, i, history, current_state, observation, prob)
    cell = get!(()->ViterbiCell(prob, history), v.V[i], current_state)
    if prob > cell.prob
        v.V[i][current_state] = ViterbiCell(prob, history)
    end
end

function decode2(v::ViterbiTrellis, i, history, current_state, observation, prob)
    if prob == NaN
        return nothing
    end
    col = v.V[i]
    if haskey(col, current_state)
        cell = col[current_state]
        if prob > cell.prob
            col[current_state] = ViterbiCell(prob, history)
        end
    else
        col[current_state] = ViterbiCell(prob, history)
    end
end


function viterbi(m::HMM, sequence)
    T, N = length(sequence), length(m.state_model.states)
    trellis = viterbi_trellis(length(sequence))
    last_state, last_label = state(m.state_model), m.state_model.start_sym
    history = [m.state_model.start_sym for i in 1:m.state_model.order]
    observation = sequence[1]
    for first_state in keys(m.state_model.states)
        p = logprob(m, history, first_state, observation)
        decode2(trellis, 1, history, first_state, observation, p)
    end
    _history = copy(history)
    max_state = ""
    max_p = -Inf
    for i in 2:T
        prev_history =
            if m.state_model.order > 1
                _history[2:end]
            else
                []
            end
        observation = sequence[i]
        max_state = ""
        max_p = -Inf
        for (prev_state, cell) in trellis.V[i-1]
            _history = [prev_history ; [prev_state]]
            st = state(m.state_model, _history)
            for next_st in keys(st.transitions)
                p = cell.prob + logprob(m, _history, next_st, observation)
                if p > max_p
                    max_p = p
                    max_state = next_st
                end
                decode2(trellis, i, _history, next_st, observation, p)
            end
        end
    end
    pred_states = []
    best_state = max_state
    for j in T:-1:1
        row = trellis.V[j]
        cell = row[best_state]
        _hist = cell.prev
        prev_state = _hist[end]
        unshift!(pred_states, best_state)
        best_state = prev_state
    end
    pred_states, max_p
end


symbol_count(m::HMM, symbol) = getcount(m.symbol_counts, symbol)
symbol_state_count(m::HMM, symbol, state) =
    getcount(m.symbol_state_counts, symbol, state)


# Calculate P(observation|state).
# In the context of the HMM, this is the emission probability
# of the observation (word) given the state (tag).
function p_state_observ(m::HMM, state, observation)
    sym_count = getcount(m.symbol_state_counts, observation, state)
    st = get(m.state_model.states, state, nothing)
    if st == nothing
        return 0
    else
        return sym_count / st.total
    end
end

# Calculate P(state|history).
# In the context of the HMM, this is the transition probability
# of 'symbol' given state history 'history'.
function p_state_cond(m::HMM, history, symbol)
    p_symbol_cond(m.state_model, history, symbol)
end

function logprob(m::HMM, history, state, observation)
    lp_obs = log(p_state_observ(m, state, observation))
    lp_seq = log(p_state_cond(m, history, state))
    return lp_obs + lp_seq                 
end
