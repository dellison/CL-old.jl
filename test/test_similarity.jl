function test_magnitude()
    v1 = sparsevec([1, 2, 3], [10, 20, 30], 100)
    v2 = sparsevec([1, 2, 4], [10, 20, 40], 100)

    @test CL.magnitude(v1) == sqrt(10^2 + 20^2 + 30^2)
    @test CL.magnitude(v2) == sqrt(10^2 + 20^2 + 40^2)

    c1 = Counter()
    inc!(c1, 1, 10)
    inc!(c1, 2, 20)
    inc!(c1, 3, 30)

    c2 = Counter()
    inc!(c2, 1, 10)
    inc!(c2, 2, 20)
    inc!(c2, 4, 40)

    @test CL.magnitude(c1) == sqrt(10^2 + 20^2 + 30^2)
    @test CL.magnitude(c2) == sqrt(10^2 + 20^2 + 40^2)
end

function test_cosine()
    v1 = sparsevec([1, 2, 3], [10, 20, 30], 100)
    v2 = sparsevec([1, 2, 4], [10, 20, 40], 100)
end

test_magnitude()
test_cosine()
