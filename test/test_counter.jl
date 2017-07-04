function test_counter1()
    c1 = Counter()
    @test getcount(c1, "no") == 0
    @test gettotal(c1) == 0
    inc!(c1, 1)
    inc!(c1, 2, 2)
    @test getcount(c1, "no") == 0
    @test getcount(c1, 1) == 1
    @test getcount( c1, 2) == 2
    @test gettotal(c1) == 3

    c2 = Counter(split("1 2 2 3 3 3"))
    @test most_frequent(c2) == "3"
    @test n_most_frequent(c2, 1) == ["3"]
    @test n_most_frequent(c2, 2) == ["3", "2"]
end

test_counter1()
