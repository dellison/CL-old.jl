function test_counter()
    c1 = Counter()
    @test count(c1, "no") == 0
    @test total(c1) == 0
    inc!(c1, 1)
    inc!(c1, 2, 2)
    @test count(c1, "no") == 0
    @test count(c1, 1) == 1
    @test count( c1, 2) == 2
    @test total(c1) == 3

    c2 = Counter(split("1 2 2 3 3 3"))
    @test most_frequent(c2) == "3"
    @test n_most_frequent(c2, 1) == ["3"]
    @test n_most_frequent(c2, 2) == ["3", "2"]
end

function test_nested_counter()
    cc = NestedCounter()
    @test total(cc) == 0
    @test count(cc, "not there") == 0

    inc!(cc, "o1", "i1")
    inc!(cc, "o1", "i2")
    inc!(cc, "o1", "i2")
    inc!(cc, "o2", "i3")
    inc!(cc, "o2", "i3")
    inc!(cc, "o2", "i3")

    @test count(cc, "o1") == 3
    @test count(cc, "o1", "i1") == 1
    @test count(cc, "o1", "i2") == 2
    @test count(cc, "o1", "i3") == 0
    @test count(cc, "o2", "i3") == 3
    @test total(cc) == 6
end
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

test_counter()
test_nested_counter()
test_sparse_vector()
