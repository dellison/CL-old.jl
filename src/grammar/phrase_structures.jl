# phrase_structures.jl

# for constituency/phrase structure trees

type PhraseStructureTree{T}
    label::T
    children::Vector{PhraseStructureTree{T}} 
end

PhraseStructureTree{T}(label::T, children) =
    PhraseStructureTree{T}(label, children)

PhraseStructureTree{T}(tag::T, word::T) =
    PhraseStructureTree{T}(tag, [PhraseStructureTree(word)])

PhraseStructureTree{T}(label::T) =
    PhraseStructureTree{T}(label, PhraseStructureTree[])

# 
# isterminal(node::PhraseStructureTree) = length(node.children) == 0

isnonterminal(node::PhraseStructureTree) = length(node.children) != 0

function isterminal(node::PhraseStructureTree)
    length(node.children) == 1 && length(node.children[1].children) == 0
end

function pp(t::PhraseStructureTree, indent=2, l_delim="(", r_delim=")")
    lstrip(_pp("", t, 1, indent, l_delim, r_delim))
end

show{T}(io::IO, t::PhraseStructureTree{T}) =
    print(io, "PhraseStructureTree{$T}\n"*pp(t, 2))

function _pp(s::String, tree::PhraseStructureTree, depth::Int, indent::Int,
             l_delim = "(", r_delim = ")")
    if isnonterminal(tree)
        s *= l_delim * tree.label
        for child in tree.children
            if isnonterminal(child)
                s *= "\n" * repeat(" ", indent * depth)
            end
            s = _pp(s, child, depth + 1, indent, l_delim, r_delim)
        end
        return s * r_delim
    else
        return s * " " * tree.label
    end
end


EMPTY_BRACKETS_RX = r"\s*\(\s*\("

"""
    bfs(t::PhraseStructureTree)

Breadth-first search the nodes of t.
"""
function bfs(t::PhraseStructureTree)
    function _it()
        q = [t]
        visited = Set()
        while length(q) > 0
            current = shift!(q)
            push!(visited, current)
            produce(current)
            for child in current.children
                if !(child in visited)
                    push!(visited, child)
                    push!(q, child)
                end
            end
        end
    end
    Task(_it)
end

"""
    bfs(f::Function, t::PhraseStructureTree)

Breadth-first search the nodes of t, calling f on each node.
Can be called with do-block synax:
bfs(tree) do node
    # do something
end
"""
function bfs(f::Function, t::PhraseStructureTree)
    for node in bfs(t)
        f(node)
    end    
end

"""
    dfs(t::PhraseStructureTree)

Depth-first search the nodes of t.
"""
function dfs(t::PhraseStructureTree)
    len = length(t.children)
    function _it()
        if len > 0
            produce(t)
            if len > 1
                for child in t.children
                    for result in dfs(child)
                        produce(result)
                    end
                end
            end
        end
    end
    Task(_it)
end

"""
    dfs(f::Function, t::PhraseStructureTree)

Depth-first search the nodes of t, calling f on each node.
Can be called with do-block synax:
dfs(tree) do node
    # do something
end
"""
# function dfs(f::Function, t::PhraseStructureTree)
#     f(t)
#     for child in t.children
#         dfs(f, child)
#     end
# end
function dfs(f::Function, t::PhraseStructureTree)
    for node in dfs(t)
        f(node)
    end
end

function tagged_sentence(t::PhraseStructureTree)
    tokens = []
    dfs(t) do node
        if length(node.children) == 1
            child = node.children[1]
            if length(child.children) == 0
                push!(tokens, (child.label, node.label))
            end
        end
    end
    tokens 
end

function normalize_tree(str::String)
    s = strip(str)
    if ismatch(EMPTY_BRACKETS_RX, s)
        s = s[2:end-1]
    end
    # replace (!) with (! !), etc.
    s = replace(s, r"\((.)\)", s"(\g<1> \g<1>)")
    # replace (tag word root) with (tag word)
    s = replace(s, r"\(([^\s()]+) ([^\s()]+) [^\s()]+\)", "(\g<1> \g<2>)")
    return s
end

type PhraseStructureTreeReader
    l_delim::String
    r_delim::String
    token_rx::Regex
end

function PhraseStructureTreeReader(l_delim::String="(", r_delim::String=")")
    let lr = l_delim * r_delim, lr_rx = "\\$l_delim\\$r_delim",
        open_rx = "\\$l_delim", close_rx = "\\$r_delim",
        # pattern is: open space*(node)?|close|(leaf)
        rx = Regex("$open_rx[ \t\n]*([^ \t\n$lr_rx]+)?|$close_rx|([^ \t\n$lr_rx]+)")
        return PhraseStructureTreeReader(l_delim, r_delim, rx)
    end 
end

function read_trees(r::PhraseStructureTreeReader, s::String)
    trees = []
    depth = 0
    start = 1
    for (i, ch) in enumerate(s)
        if string(ch) == r.l_delim
            depth += 1
        elseif string(ch) == r.r_delim
            depth -= 1
            if depth == 0
                tree_s = s[start:i]
                push!(trees, read_tree(r, tree_s))
                start = i+1
            end
        end
    end
    return trees
end

function read_tree(r::PhraseStructureTreeReader, s::String)
    tokens = String[]
    productions = []
    skip_close = false
    # keep track of a stack of trees
    stack = []
    push!(stack, (nothing, PhraseStructureTree[]))
    for tokenm in eachmatch(r.token_rx, s)
        token = tokenm.match
        l, r_ = tokenm.captures
        if startswith(token, r.l_delim)
            if l === nothing
                skip_close = true
                continue
            else # beginning of a tree
                if length(stack) == 1 && length(stack[1][2]) > 0
                    error("parse error as $token")
                end
                push!(stack, (l, PhraseStructureTree[]))                
            end
        elseif r_ != nothing # leaf node
            if length(stack) == 1
                error("parse error as $token")
            end
            push!(tokens, token)
            push!(stack[end][2], PhraseStructureTree(token))
        else # end of a tree
            if length(stack) == 1
                if skip_close
                    continue
                else
                    error("parse error at $token")
                end
            end
            node, children = pop!(stack)
            push!(stack[end][end], PhraseStructureTree(node, children))
            push!(productions, (node, [child.label for child in children]))
        end
    end
    tree = stack[1][2][1]
end

read_tree(s::String) = read_tree(PhraseStructureTreeReader(),s)
