import CL: entropy

function test_entropy()

    dist1 = Counter([1,2])
    @test entropy(dist1) == 1.0 # one bit

    dist2 = Counter(Dict("one"=>1, "two"=>2))
    @test entropy(dist2) == -(1/3)*(log2(1/3)) - (2/3)*(log2(2/3))
end

test_entropy()
