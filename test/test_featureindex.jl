function test_featureindex()

    idx = CL.FeatureIndex(["feature_$i" for i = 1:100])
    for i = 1:100
        @test CL.feature(idx, i) == "feature_$i"
        @test CL.index(idx, "feature_$i") == i
    end

    @test CL.index(idx, "doesntexist") == 101

end

test_featureindex()
