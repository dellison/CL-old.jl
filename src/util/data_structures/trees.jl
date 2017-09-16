module Trees

import Base: show

type TreeNode{T}
    label::Nullable{String}
    data::Nullable{T}
    children::Vector{TreeNode}
end

# TreeNode(label::String) = TreeNode{Any}(label, nothing, TreeNode[])
function TreeNode(t::Type=Any; label=nothing, data=nothing, children=TreeNode[])
    TreeNode{t}(label, nothing, children)
end

function TreeNode(label; data=nothing, children=TreeNode[])
    TreeNode(Any, label=label, data=nothing, children=children)
end
# TreeNode(DT, "the") for example
# TreeNode(label::String, leaf::String) =
#     TreeNode{Any}(label, nothing, [TreeNode(leaf)])

# TreeNode(S, [NP, VP])
# TreeNode(label::String, children::Vector{TreeNode}) =
#     TreeNode{Any}(label, nothing, children)

# 
# TreeNode(t::Type) = TreeNode{t}(nothing, nothing, TreeNode[])


function show(io::IO, node::TreeNode)
    label = get(node.label, "*")
    c = try length(get(node.children)) catch 0 end
    if c > 0
        print(io, "TreeNode($label, $c children)")
    else
        print(io, "TreeNode($label)")
    end 
end

label(t::TreeNode, default="") = get(t.label, default)
data(t::TreeNode, default=nothing) = get(t.data, default)
function children(t::TreeNode)
    function task()
        for child in t.children
            produce(child)
        end
    end
    return Task(task)
end

function isleaf(t::TreeNode)
    length(t.children) == 0
end

function isbranch(t::TreeNode)
    length(t.children) > 0
end

function add_child!(t::TreeNode, c::TreeNode)
    push!(t.children, child)    
end

# breadth-first search, depth-first search

function bfs(t::TreeNode)
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

function bfs(f::Function, t::TreeNode)
    for node in bfs(t)
        f(node)
    end    
end

function dfs(t::TreeNode)
    function f()
        produce(t)
        for child in children(t), node in dfs(child)
            produce(node)
        end
    end
    Task(f)
end

function dfs(f::Function, t::TreeNode)
    for node in dfs(t)
        f(node)
    end
end

immutable TreeTokenizer
    open_token::String
    close_token::String
    token_rx::Regex
end

function TreeTokenizer(l_delim::String="(", r_delim::String=")")
    let lr = l_delim * r_delim, lr_rx = "\\$l_delim\\$r_delim",
        open_rx = "\\$l_delim", close_rx = "\\$r_delim",
        # pattern: open space*(node)?|close|(leaf)
        rx = Regex("$open_rx[ \t\n]*([^ \t\n$lr_rx]+)?|$close_rx|([^ \t\n$lr_rx]+)")
        return TreeTokenizer(l_delim, r_delim, rx)
    end 
end

function read_trees(trees, open_token="(", close_token=")")
    tokenizer = TreeTokenizer(open_token, close_token)
    function f()
        for tree in trees
            produce(read_tree(tokenizer, tree))
        end
    end
    Task(f)
end

read_tree(s::String) = read_tree(TreeTokenizer(), s)

function read_tree(tok::TreeTokenizer, s::String)
    tokens = String[]
    productions = []
    skip_close = false
    # keep track of a stack of trees
    stack = []
    push!(stack, (nothing, TreeNode[]))
    for tokenm in eachmatch(tok.token_rx, s)
        token = tokenm.match
        l, r_ = tokenm.captures
        if startswith(token, tok.open_token)
            if l === nothing
                skip_close = true
                continue
            else # beginning of a tree
                if length(stack) == 1 && length(stack[1][2]) > 0
                    error("parse error as $token")
                end
                push!(stack, (l, TreeNode[]))                
            end
        elseif r_ != nothing # leaf node
            if length(stack) == 1
                error("parse error as $token")
            end
            node = TreeNode(String(token))
            push!(tokens, token)
            push!(stack[end][2], node)
        else # end of a tree
            if length(stack) == 1
                if skip_close
                    continue
                else
                    error("parse error at $token")
                end
            end
            node, children = pop!(stack)
            push!(stack[end][end], TreeNode(node, children=children))
            push!(productions, (node, [child.label for child in children]))
        end
    end
    tree = stack[1][2][1]
end


end # module
