function octree_path = octree_paths_from_chunk_ijk1s(chunk_ijk1s, level_step_count)
    chunk_ijk0s = chunk_ijk1s - 1 ;
    row_count = size(chunk_ijk1s, 1) ;
    octree_path = zeros(row_count, level_step_count) ;
    for idx =  1:row_count ,
        chunk_ijk0_this = chunk_ijk0s(idx,:) ;
        bits = bits_from_chunk_ijk0(chunk_ijk0_this, level_step_count) ;        
        % Convert to octant code for each coordinate
        octree_path(idx,:) = octree_path_from_bits(bits) ;
    end
end



function bits = bits_from_chunk_ijk0(chunk_ijk0, level_step_count)
    % chunk_ijk0 is 1 x 3
    % level_step_count is the number of levels in the octree minus one
    % bits is level_step_count x 3, columns correspond to xyz.
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level, in that
    % dimension.
    bits = zeros(level_step_count, 3) ;
    for j = 1:3 ,
        n = chunk_ijk0(j) ;
        n_in_binary = bitget(n, level_step_count:-1:1) ;
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
    % result is 1 x level_step_count, which each element giving the
    % morton-ordered octant for each level of the octree.
    % i.e. morton_octant_index = 1 + x_bit + 2*y_bit + 4*z_bit
    result = (1 + sum(bits .* [1 2 4], 2))' ;
end
