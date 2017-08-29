import CL: Alphabet

function test_alphabet()
    a = Alphabet()

    @test a["lol"] == 1
    @test a["lol"] == 1
    @test a["lol2"] == 2

    @test "lol" in a
    @test "lol2" in a

    a = Alphabet(split("one two three"))
    @test a["one"] == 1
    @test a["two"] == 2
    @test a["three"] == 3
    
    @test !("four" in a)
    @test a["four"] == 4
    @test "four" in a
end

test_alphabet()
