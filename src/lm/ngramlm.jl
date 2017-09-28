# const BOS = "<start>"
# const EOS = "<end>"

type NGramLM{T,N<:Number}
    n::Int
    model::MarkovModel{T,N}
    total::Int
    # bos::String
    # eos::String

    function NGramLM(n; bos = "BOS", eos = "EOS")
        new(n, MarkovModel{T,N}(n-1, start_sym = bos, end_sym = eos), 0)
    end
end

NGramLM(n; bos = "BOS", eos = "EOS") = NGramLM{Any,Int}(n, bos=bos, eos=eos)

bigram_lm() = NGramLM(2)
trigram_lm() = NGramLM(3)
ngram_lm(n) = NGramLM(n)

function train!(m, sequence)
    train!(m.model, sequence)
    m.total += length(sequence)
end
       
generate(m, n=0) = generate(m.model, n)
generates(m, sep=" ") = join(generate(m), sep)

bos(lm::NGramLM) = lm.model.start_sym
eos(lm::NGramLM) = lm.model.end_sym

# gram(lm::NGramLM, sentence, i) = sentence[i:i+lm.model.order]

function gram(lm::NGramLM, sentence, i)
    f(x) = x >= 1 ? sentence[x] : MARKOV_START
    map(f, i-lm.model.order:i)
end

function hist(lm::NGramLM, sentence, i)
    f(x) = x >= 1 ? sentence[x] : MARKOV_START
    map(f, i-lm.model.order:i-1)
end

# sentence[i:i+lm.model.order-1]

function c(lm::NGramLM, word)
    st = state(lm.model, word)
    st.total
end

function c(lm::NGramLM, word, history)
    if length(history) == 0
        return c(lm, word)
    end
    st = state(lm.model, history)
    weight(st, word)
end
    
"""

    p_mle(lm, gram)

Maximum Likelihood Estimation of the probability of the gram.

``p(word|history) = c(history+word) / c(history)``
"""
function p_mle(lm::NGramLM, gram)
    if length(gram) == 1
        return c(lm, gram[1]) / lm.total
    end
    word, prev = gram[end], gram[1:end-1]
    st = state(lm.model, prev)
    weight(st, word) / st.total
end

"""
    p_mle(lm, gram)

Estimate of the probability of the gram, using add-1 smoothing.

``p(word|history) = c(history+word) / c(history)``
"""
function p_add1(lm::NGramLM, gram)
    if length(gram) == 1
        w = c(lm, gram[1])
        return (w+1) / (lm.total+1)
    else
        word, prev = gram[end], gram[1:end-1]
        st = state(lm.model, prev)
        w = weight(st, word)
        return (w+1) / (st.total+1)
    end
end

"""
    p_linint(lm, gram, alpha)

Estimate of the probability of the gram, using linear interpolation.
Alpha should be a vector of floats that sum to 1 (forming a
probability distribution). 
"""
function p_linint(lm::NGramLM, ngram, alpha)
    if sum(alpha) != 1.0
        error("alpha terms for smoothing must add up to 1.0")
    elseif length(alpha) != length(ngram)
        error("ngram and alpha must be the same length")
    else
        prob = 0.0
        for m = lm.model.order:-1:1
            g = ngram[lm.n-m:end]
            # @show g
            a = alpha[end-m+1]
            # println("+ ($a * $(p_mle(lm, g)))")
            prob += a * p_mle(lm, g)
        end
        return prob
    end
end    


"""
    ppl(lm, prob_fn, sentence)

"""
function ppl(lm::NGramLM, prob_fn::Function, sentence)
    for i = 1:length(s)
        prob_fn(lm, gram(lm, sentence, i))
    end
end
