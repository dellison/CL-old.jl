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

test_counter()
test_nested_counter()
