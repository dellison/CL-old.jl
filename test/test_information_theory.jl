import CL: entropy

function test_entropy()
    dist1 = Counter([1,2])
    @test entropy(dist1) == 1.0 # one bit

    dist2 = Counter(Dict("one"=>1, "two"=>2))
    @test entropy(dist2) == -(1/3)*(log2(1/3)) - (2/3)*(log2(2/3))

    xy = NestedCounter()
    for word in ["it", "was", "great"]
        inc!(xy, word, "pos")
    end
    for word in ["it", "was", "awful"]
        inc!(xy, word, "neg")
    end

    plogp(p) = p*log2(p)
    #                      it           was          great        awful
    entropy_words = -plogp(2/6) - plogp(2/6) - plogp(1/6) - plogp(1/6)
    @test_approx_eq(entropy(xy), entropy_words)

    entropy_it = -plogp(1/2) - plogp(1/2)
    @test_approx_eq(entropy(xy, "it"), entropy_it)
end

test_entropy()
