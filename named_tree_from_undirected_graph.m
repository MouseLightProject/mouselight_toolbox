function result = named_tree_from_undirected_graph(A_tree_raw, xyz_raw, name, color)
    % Process args
    if ~exist('color', 'var') || isempty(color) ,
        color_map_count = 256 ;
        color_map = jet(color_map_count) ;
        color_index = mod(sum(double(name)), color_map_count) + 1 ;  
          % Want a "random" number that is nonetheless determined by the
          % inputs, so we use the world's dumbest hash function.
        color = color_map(color_index,:) ;
    end
    
    % This will be useful
    node_count = size(A_tree_raw,1) ;

    if node_count==0 ,
        result = struct('name', name, ...
                        'color', color, ...
                        'xyz', zeros(0,3), ...
                        'r', zeros(0,1), ...
                        'parent', zeros(0,1), ...
                        'tag_code', zeros(0,1)) ;
        return
    end        
    
    % Traverse the graph in depth-first order from the root, allowing us to order
    % the nodes topologically.
    degree = full(sum(A_tree_raw)) ;
    [~, root_node_id] = min(degree) ;  % min degree should always be 1
    disc = graphtraverse(A_tree_raw, root_node_id, 'Method', 'DFS') ;
    
    % Reorder everything so things are in topological order (and unused
    % node ids are eliminated)
    A_tree = A_tree_raw ;
    A_tree(1:end,:) = A_tree(disc,:) ;
    A_tree(:,1:end) = A_tree(:,disc) ;
    xyz = xyz_raw(disc,:) ;
    r = ones(node_count,1) ;
    d = ones(node_count,1) ;
        
    % Get the predecessor (parent) of each node
    %[~,~,pred_slow_as_row] = graphshortestpath(A,1,'DIRECTED',false);
    %pred_slow = pred_slow_as_row(:) ;
    dA = tril(A_tree) ;  % the directed adjacency graph of A
    [is,js] = ind2sub(size(dA), find(dA)) ;
    pred = zeros(node_count, 1) ;
    pred(is) = js ;
    %assert(all(pred==pred_slow)) ;
    
    % Package things as a named tree struct
    parent = pred ;
    if node_count >= 1 ,
        parent(1) = -1 ;  % the swc convention is that the root parent is -1
    end
    result = struct('name', name, ...
                    'color', color, ...
                    'xyz', xyz, ...
                    'r', r, ...
                    'parent', parent, ...
                    'tag_code', d) ;
end
