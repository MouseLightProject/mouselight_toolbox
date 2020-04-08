function node_ids_from_chain_id = chains_from_tree(A_tree, root_node_id)
    % Given symmetric adjacency matrix A representing an undirected tree,
    % returns a set of chains.  The first and last node of each chain is a
    % node_id into A, and each is a nexus node.  All nodes in A are
    % included in at least one chain.

%     % For debugging
%     G = graph(dA) ;
%     figure() ;
%     plot(G) ;

    if isempty(A_tree) ,
        node_ids_from_chain_id = cell(1,0) ;
        return
    end

    % Select a root node, if none supplied
    if ~exist('root_node_id', 'var') || isempty(root_node_id) ,
        % Use a branch node as the root, unless none exist, if which case
        % use a leaf node.
        % Note that unless A_tree is a chain, this guarantees that each
        % leaf node is the start of exactly one chain, and that each chain end
        % is a branch node.
        degree_from_node_id = full(sum(A_tree)) ;
        branch_node_ids = find(degree_from_node_id>=3) ;
        if ~isempty(branch_node_ids) ,
            root_node_id = branch_node_ids(1) ;
        else
            leaf_node_ids = find(degree_from_node_id==1) ;
            if ~isempty(leaf_node_ids) ,
                root_node_id = leaf_node_ids(1) ;
            else
                error('A_tree has no branch nodes and no leaf nodes: Cannot be a tree')
            end
        end
    end
    
    % Get a rooted directed tree from the undirected tree
    % The 'root' node will basically be a random leaf, which is what we
    % want.
    %dA = spanning_tree_adjacency_from_graph_adjacency(A_tree) ;    
    dA = rooted_tree_from_connected_graph(A_tree, root_node_id) ;
    
    % 
    node_ids_from_chain_id = chains_from_rooted_tree(dA) ;
end
