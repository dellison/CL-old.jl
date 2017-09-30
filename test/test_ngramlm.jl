
import CL: gram, hist, p, p_mle, p_add1, p_linint

function test_lm()
    corpus = map(split, ["i am from pittsburgh .",
                         "i study at university .",
                         "my mother is from utah ."])
    lm = bigram_lm()
    for sentence in corpus
        train!(lm, sentence)
    end

    sent1 = corpus[1]
    @test gram(lm, sent1, 1) == ["BOS","i"]
    @test hist(lm, sent1, 1) == ["BOS"]

    @test CL.c(lm, "from") == 2
    @test CL.c(lm, "i") == 2
    @test CL.c(lm, "university") == 1
    @test CL.c(lm, "didntappear") == 0
    
    @test CL.c(lm, "i", ["BOS"]) == 2
    @test CL.c(lm, "am", ["i"]) == 1
end

function test_trigramlm()
    corpus = map(split, ["i am from pittsburgh .",
                         "i study at university .",
                         "my mother is from utah ."])
    lm = trigram_lm()
    for sentence in corpus
        train!(lm, sentence)
    end

    sent1 = corpus[1]
    @test gram(lm, sent1, 1) == ["BOS", "BOS","i"]
    @test hist(lm, sent1, 1) == ["BOS", "BOS"]
    
    @test CL.c(lm, "i") == 2
    @test CL.c(lm, "i", []) == 2
    @test CL.c(lm, "from") == 2
    @test CL.c(lm, "am", ["i"]) == 1
    @test CL.c(lm, "from", ["i", "am"]) == 1
    @test CL.c(lm, "i", [CL.bos(lm)]) == 2
    @test CL.c(lm, "i", [CL.bos(lm), CL.bos(lm)]) == 2
    @test CL.c(lm, "am", [CL.bos(lm), "i"]) == 1
    @test CL.c(lm, "from", CL.bos(lm)) == 0

    @test p_mle(lm, ["i"]) == 2/16
    @test p_mle(lm, ["am"]) == 1/16
    @test p_add1(lm, ["am"]) == 2/17
    @test p_mle(lm, ["i", "am"]) == p_mle(lm, ["i", "study"]) == 0.5
    @test p_add1(lm, ["i", "am"]) == p_add1(lm, ["i", "study"]) == 2/3

    # @show p_linint(lm, ["i", "am"], [1.0, 0.0])
    @test p_linint(lm, ["i", "am"], [0.0, 1.0]) == (2/16) * (1/2)
end

test_lm()
test_trigramlm()
