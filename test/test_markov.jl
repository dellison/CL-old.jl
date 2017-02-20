function test_markov_state()
    state = CL.MarkovState()
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

test_markov_state()
test_markov_models()
