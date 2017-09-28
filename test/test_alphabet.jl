import CL: Alphabet, alphabet, add, add_many, lookup, lookup_many, plaintext, freeze!, stop_growth!

function test_alphabet()
    a = Alphabet()

    @test a["lol"] == 1
    @test a["lol"] == 1
    @test a["lol2"] == 2

    @test "lol" in a
    @test "lol2" in a

    @test lookup(a, 1) == "lol"
    @test lookup(a, 2) == "lol2"

    a = alphabet(split("one two three"))
    @test a["one"] == 1
    @test a["two"] == 2
    @test a["three"] == 3
    
    @test !("four" in a)
    @test a["four"] == 4
    @test "four" in a

    @test plaintext(a) == "one\ntwo\nthree\nfour"

    add_many(a, ["five", "six", "seven", "eight"])
    @test lookup_many(a, 5:8) == ["five", "six", "seven", "eight"]

    stop_growth!(a)
end

test_alphabet()

