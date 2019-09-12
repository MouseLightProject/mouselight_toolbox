function [octree_path, ijks_within_chunk] = octree_path_from_ijk(ijks, level_step_count, chunk_shape)
    % Converts ijk location to oct location.
    %
    % level_step_count is the number of levels in the octree, i.e. the length of the path to a leaf stack
    % chunk_shape is the shape of the leaf stacks in the octree, in ijk/xyz order
    % ijk is in voxels, and is one-based.  Values should be integral.
    % ijk is n x 3
    % chunk_shape is the chunk shape at the bottom level of the tree, i.e. the most zoomed-in level
    % Returns two things: First is the octree path, an n x level_step_count array, row i
    %                         the path to the leaf stack for ijks(i,:).
    %                     Second n x 3, row i giving the ijks position in the
    %                         leaf stack for ijks(i,:).

    row_count = size(ijks, 1) ;
    octree_path = zeros(row_count, level_step_count) ;
    ijks_within_chunk = zeros(row_count, 3) ;
    for idx =  1:row_count ,
        ijk_remnant_zero_based = ijks(idx,:)-1 ;
        bits = zeros(level_step_count, 3) ;
        for i = 1:level_step_count ,
            n = level_step_count-i ;
            halfway_index_at_this_level = (2^n) * chunk_shape ;
            bits_at_this_level = (ijk_remnant_zero_based>halfway_index_at_this_level) ;
            bits(i, :) = bits_at_this_level ;
            ijk_remnant_zero_based = ijk_remnant_zero_based - halfway_index_at_this_level .* bits_at_this_level ;
        end
        
        % Convert to octant code for each coordinate
        octree_path(idx,:) = (1 + sum(bits .* [1 2 4], 2))' ;
        ijks_within_chunk(idx,:) = ijk_remnant_zero_based + 1 ;
    end
end
