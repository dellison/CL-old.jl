using CL: PhraseStructureTree, read_tree, dfs, isterminal

function test_tree()
    sentence = """( (S 
    (NP-SBJ 
      (NP (NNP Pierre) (NNP Vinken) )
      (, ,) 
      (ADJP 
        (NP (CD 61) (NNS years) )
        (JJ old) )
      (, ,) )
    (VP (MD will) 
      (VP (VB join) 
        (NP (DT the) (NN board) )
        (PP-CLR (IN as) 
          (NP (DT a) (JJ nonexecutive) (NN director) ))
        (NP-TMP (NNP Nov.) (CD 29) )))
    (. .) ))"""

    t = read_tree(sentence)
    @test t.label == "S"
    npsubj, vp = t.children
    @test npsubj.label == "NP-SBJ"
    @test vp.label == "VP"

    wd(n) = n.children[1].label
    words = [wd(node) for node in dfs(t) if isterminal(node)]
    gold_words = split("Pierre Vinken , 61 years old , will join the board as a nonexecutive director Nov. 29 .")
    @test words == gold_words
end

test_tree()
