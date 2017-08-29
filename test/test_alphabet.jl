import CL: Alphabet, lookup, plaintext

function test_alphabet()
    a = Alphabet()

    @test a["lol"] == 1
    @test a["lol"] == 1
    @test a["lol2"] == 2

    @test "lol" in a
    @test "lol2" in a

    @test lookup(a, 1) == "lol"
    @test lookup(a, 2) == "lol2"

    a = Alphabet(split("one two three"))
    @test a["one"] == 1
    @test a["two"] == 2
    @test a["three"] == 3
    
    @test !("four" in a)
    @test a["four"] == 4
    @test "four" in a

    @test plaintext(a) == "one\ntwo\nthree\nfour"
end

test_alphabet()
