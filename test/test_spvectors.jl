function test_sparse_vector()
    v = spvec()

    set!(v, "one", 0.1)
    set!(v, "two", 0.2)
    set!(v, "three", 0.3)
        
    @test weight(v, "one") == 0.1
    @test weight(v, "two") == 0.2
    @test weight(v, "three") == 0.3

    @test_approx_eq total(v) 0.6
    @test_approx_eq magnitude(v) sqrt(0.1^2 + 0.2^2 + 0.3^2)

    inc!(v, "one", 1)
    @test weight(v, "one") == 1.1
    @test_approx_eq total(v) 1.6
    @test_approx_eq magnitude(v) sqrt(1.1^2 + 0.2^2 + 0.3^2)
end

test_sparse_vector()
