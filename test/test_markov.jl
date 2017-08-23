import CL: MarkovModel, MarkovState, HMM

import CL: p_state_cond, p_state_observ, viterbi

function test_markov_state()
    state = MarkovState()
    inc!(state, "a")
    inc!(state, "b")
    inc!(state, "b")
    @test CL.weight(state, "a") == 1
    @test state.total == 3
end

function test_markov_models()
    m = CL.MarkovModel(1)
    train!(m, ["hello", "there"])
    train!(m, ["hello"])
end

function test_bigram_hmm()
    m = HMM(1) # first-order markov model

    corpus = ["the/DT cat/NN ate/VBD ./.",
              "the/DT dogs/NNS ate/VBD food/NN ./.",
              "cats/NNS ate/VBD ./.",
              "cop/NN dogs/VBZ suspect/NN"]
    for sent in corpus
        train!(m, map(tkn->split(tkn,"/"), split(sent)))
    end

    bos_history = [m.state_model.start_sym]

    @test p_state_cond(m, bos_history, "DT") == 1/2
    @test p_state_cond(m, bos_history, "NN") == 1/4
    @test p_state_cond(m, bos_history, "NNS") == 1/4

    @test p_state_cond(m, bos_history, "DT") == 1/2
    @test p_state_cond(m, ["DT"], "NNS") == 1/2
    @test p_state_cond(m, ["NNS"], "VBD") == 1.0
    @test p_state_cond(m, ["VBD"], ".") == 2/3

    @test p_state_observ(m, "DT", "the") == 1.0
    @test p_state_observ(m, "VBZ", "dogs") == 1.0
    @test p_state_observ(m, "NNS", "dogs") == 0.5

    states, lprob = CL.viterbi(m, split("the dogs ate ."))

    p_the_dt = 1.0 * 0.5     # P(the|DT) * P(DT|<BOS>)
    p_dogs_nns = 0.5 * (1/2) # P(dogs|NNS) * P(NNS|DT)
    p_ate_vbd = 1.0 * 1.0    # P(ate|VBD) * P(VBD|NNS)
    p_period = 1.0 * (2/3)   # P(.|.) * P(.|VBD)

    sent_prob = log(p_the_dt) + log(p_dogs_nns) + log(p_ate_vbd) + log(p_period)
    @test sent_prob == lprob
end

function test_trigram_hmm()
    m = HMM(2)
    corpus = []
    bos_history = [m.state_model.start_sym,m.state_model.start_sym]
end

test_markov_state()
test_markov_models()
test_bigram_hmm()
test_trigram_hmm()
