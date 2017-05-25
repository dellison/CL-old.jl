function test_featureindex()

    idx = CL.FeatureIndex(["feature_$i" for i = 1:100])
    for i = 1:100
        @test CL.feature(idx, i) == "feature_$i"
        @test CL.index(idx, "feature_$i") == i
    end

    @test CL.index(idx, "doesntexist") == 101

    idx = CL.FeatureIndex(["feature_$i" for i = 1:100], max=99)
    for i = 1:99
        @test CL.feature(idx, i) == "feature_$i"
        @test CL.index(idx, "feature_$i") == i
    end
    @test CL.feature(idx, "feature_100") == 0

    @test CL.index(idx, "feature_100") == 0
    @test CL.index(idx, "doesntexist") == 0

end

test_featureindex()
