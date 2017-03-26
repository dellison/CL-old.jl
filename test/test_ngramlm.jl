
function test_lm()
    corpus = map(split, ["i am from pittsburgh .",
                         "i study at university .",
                         "my mother is from utah ."])
    lm = bigram_lm()
    for sentence in corpus
        train!(lm, sentence)
    end

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
    
    @test CL.c(lm, "i") == 2
    @test CL.c(lm, "i", []) == 2
    @test CL.c(lm, "from") == 2
    @test CL.c(lm, "am", ["i"]) == 1
    @test CL.c(lm, "from", ["i", "am"]) == 1
    @test CL.c(lm, "i", [CL.bos(lm)]) == 2
    @test CL.c(lm, "i", [CL.bos(lm), CL.bos(lm)]) == 2
    @test CL.c(lm, "am", [CL.bos(lm), "i"]) == 1
    @test CL.c(lm, "from", CL.bos(lm)) == 0
end

test_lm()
test_trigramlm()
