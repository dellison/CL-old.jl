using CL.Trees: read_tree, label, dfs, bfs, isleaf

function test_phrase_structure_trees()
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
    
    @test label(t) == "S"
    npsubj, vp = t.children
    @test label(npsubj) == "NP-SBJ"
    @test label(vp) == "VP"

    # wd(n) = n.children[1].label
    words = [label(node) for node in dfs(t) if isleaf(node)]
    gold_words = split("Pierre Vinken , 61 years old , will join the board as a nonexecutive director Nov. 29 .")
    @test words == gold_words

    words2 = [label(node) for node in bfs(t) if isleaf(node)]
end

test_phrase_structure_trees()
