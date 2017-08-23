import CL: argmax

function test_argmax()
    c = Counter(Dict(i=>i for i in 1:10))
    @test argmax(c) == 10

    v = spvec(Dict("$i"=>i for i in 1:10))
    @test argmax(c) == 10

    @test argmax(abs, [1, 2, 3, -5]) == -5
    @test argmax(x->x, [0]) == 0
end

test_argmax()
