using CL: c, argmax, spvec, magnitude, dot, cosine, euclid_dist

function test_counter()

    c1 = Counter()
    @test c(c1, "no") == 0
    @test total(c1) == 0
    inc!(c1, 1)
    inc!(c1, 2, 2)
    @test c(c1, "no") == 0
    @test c(c1, 1) == 1
    @test c( c1, 2) == 2
    @test total(c1) == 3

    c2 = Counter(split("1 2 2 3 3 3"))
    @test argmax(c2) == most_frequent(c2) == "3"
    @test n_most_frequent(c2, 1) == ["3"]
    @test n_most_frequent(c2, 2) == ["3", "2"]
end

function test_nested_counter()
    cc = NestedCounter()
    @test total(cc) == 0
    @test c(cc, "not there") == 0

    inc!(cc, "o1", "i1")
    inc!(cc, "o1", "i2")
    inc!(cc, "o1", "i2")
    inc!(cc, "o2", "i3")
    inc!(cc, "o2", "i3")
    inc!(cc, "o2", "i3")

    @test c(cc, "o1") == 3
    @test c(cc, "o1", "i1") == 1
    @test c(cc, "o1", "i2") == 2
    @test c(cc, "o1", "i3") == 0
    @test c(cc, "o2", "i3") == 3
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

    a = spvec("one"=>1, "two"=>2, "ten"=>10)
    b = spvec("one"=>1, "two"=>2, "five"=>5)

    # transitivity sanity check
    @test cosine(a, b) == cosine(b, a)
    @test euclid_dist(a, b) == euclid_dist(b, a)
    @test dot(a, b) == dot(b, a)

    @test dot(a, a) == 105
    @test dot(b, b) == 30
    @test dot(a, b) == 5

    @test_approx_eq cosine(a, a) cosine(b, b)
    @test_approx_eq cosine(a, a) 1
    @test_approx_eq (5/(sqrt(105)*sqrt(30))) cosine(a, b)
end

import CL: p

function test_probability()
    # MLE
    dist = Counter()
    inc!(dist, "one", 1)
    inc!(dist, "two", 2)
    inc!(dist, "three", 3)
    inc!(dist, "four", 4)
    inc!(dist, "five", 5)

    n = sum(1:5)
    @test p(dist, "one") == 1/n
    @test p(dist, "two") == 2/n
    @test p(dist, "three") == 3/n
    @test p(dist, "four") == 4/n
    @test p(dist, "five") == 5/n

    n1 = n + 1
    @test p(dist, "ZERO", smooth="add1") == 1/n1
    @test p(dist, "one", smooth="add1") == 2/n1
    @test p(dist, "two", smooth="add1") == 3/n1
    @test p(dist, "three", smooth="add1") == 4/n1
    @test p(dist, "four", smooth="add1") == 5/n1
    @test p(dist, "five", smooth="add1") == 6/n1
end

test_counter()
test_nested_counter()
test_sparse_vector()
test_probability()
