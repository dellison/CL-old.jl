function test_counter1()
    c1 = Counter()
    @test getcount(c1, "no") == 0
    @test gettotal(c1) == 0
end

test_counter1()
