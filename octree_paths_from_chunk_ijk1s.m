function octree_path = octree_paths_from_chunk_ijk1s(chunk_ijk1s, zoom_level)
    % An 'octree' with at least zoom-level+1 levels of resolution will have 8^zoom_level chunks at
    % zoom level zoom_level.  (Meaning the level at which it requires
    % zoom_level octal digits to uniquely specify a chunk.)
    % This function converts from chunk coordinates chunk_ijk1s
    % to the corresponding octree paths.
    %
    % Here, by "the coordinates of a chunk", we mean: Taking the full stack
    % to consist of a 2^zoom_level x 2^zoom_level x 2^zoom_level array of
    % chunks, the coordinate of a chunks is the 1 x 3 array of integers
    % specifying the location of the chunk in each dimension.
    %
    % Each row of chunk_ijk1s should be 1 x 3, giving the coordinates of a
    % chunk in xyz order, using one-based indexing.  Thus each element of
    % chunk_ijk1s should be an integer on [1, 2^zoom_level].
    %
    % On output, each row has zoom_level elements, and gives the octree
    % path to the chunk, as a sequence of morton-coded octants.
    
    chunk_ijk0s = chunk_ijk1s - 1 ;
    row_count = size(chunk_ijk1s, 1) ;
    octree_path = zeros(row_count, zoom_level) ;
    for idx =  1:row_count ,
        chunk_ijk0_this = chunk_ijk0s(idx,:) ;
        bits = bits_from_chunk_ijk0(chunk_ijk0_this, zoom_level) ;        
        % Convert to octant code for each coordinate
        octree_path(idx,:) = octree_path_from_bits(bits) ;
    end
end



function bits = bits_from_chunk_ijk0(chunk_ijk0, zoom_level)
    % chunk_ijk0 is 1 x 3
    % zoom_level is the number of octal digits needs to specify a leaf at
    % the current zoom level.  So zoom_level 0 means there's only one leaf,
    % zoom_level 1 means there's 8^1 leaves, zoom level n means theres 8^n
    % leaves.
    % bits is zoom_level x 3, columns correspond to xyz.
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level, in that
    % dimension.
    bits = zeros(zoom_level, 3) ;
    for j = 1:3 ,
        n = chunk_ijk0(j) ;
        n_in_binary = bitget(n, zoom_level:-1:1) ;
        bits(:,j) = n_in_binary' ;
    end
%     for i = 1:level_step_count ,
%         n = level_step_count-i ;  % e.g. if level_step_count is 6, then n goes from 5 down to 0
%         halfway_index_at_this_level = (2^n) ;
%         bits_at_this_level = (chunk_ijk0_remnant>=halfway_index_at_this_level) ;
%         bits(i, :) = bits_at_this_level ;
%         chunk_ijk0_remnant = chunk_ijk0_remnant - halfway_index_at_this_level .* bits_at_this_level ;
%     end
end



function result = octree_path_from_bits(bits)
    % bits is level_step_count x 3, and each element is 0 or 1
    % The three columns are x, y, z
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level.
    % result is 1 x zoom_level, which each element giving the
    % morton-ordered octant for each level of the octree.
    % i.e. morton_octant_index = 1 + x_bit + 2*y_bit + 4*z_bit
    result = (1 + sum(bits .* [1 2 4], 2))' ;
end
