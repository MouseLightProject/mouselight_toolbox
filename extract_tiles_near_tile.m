function [tile_index_from_tile_ijk1, ...
          tile_ijk1_from_tile_index, ...
          xyz_from_tile_index, ...
          relative_path_from_tile_index] = ...
        extract_tiles_near_tile(...
            full_tile_index_from_full_tile_ijk1, ...
            full_tile_ijk1_from_full_tile_index, ...
            xyz_from_full_tile_index, ...
            relative_path_from_full_tile_index, ...
            center_tile_relative_path) 

    % Extracts a 3x3x3 subset of tiles around a given central tile.
    % Good for running analysis on a small subset of tiles
    %
    % The full_tile_index is the index of a tile in the full tile set.
    % The tile_index is the index of a tile withing the extracted subset.
    % Currently the extracted subset is always a 3x3x3 cuboid of tiles.
    
    % Get the full tile index of the center tile
    is_center_tile_from_full_tile_index = strcmp(center_tile_relative_path, relative_path_from_full_tile_index) ;
    center_tile_full_index = find(is_center_tile_from_full_tile_index) ;
    
    % Get the one-based ijk (integral xyz) coordinates of the center tile
    % within the full tile block
    center_tile_full_ijk1 = full_tile_ijk1_from_full_tile_index(center_tile_full_index, :) ;  %#ok<FNDSB>
                               
    % Get the 3x3x3 array of file tile indices around the central tile
    full_tile_index_from_tile_ijk1 = ...
        full_tile_index_from_full_tile_ijk1(center_tile_full_ijk1(1)-1:center_tile_full_ijk1(1)+1, ...
                                            center_tile_full_ijk1(2)-1:center_tile_full_ijk1(2)+1, ...
                                            center_tile_full_ijk1(3)-1:center_tile_full_ijk1(3)+1) ;
                                        
    % The raw tile index is the index of each tile within the 3x3x3 block.
    % The actual tile index may differ because some tiles may be missing.
    % Missing tiles in full_tile_index_from_full_tile_ijk1 are represented by
    % nans.    
    
    % Get the array that maps from raw tile indices to full tile indices
    full_tile_index_from_raw_tile_index = full_tile_index_from_tile_ijk1(:) ;  % may have nans for missing tiles
    
    % Get the mapping from tile indices to raw tile indices
    raw_tile_count = length(full_tile_index_from_raw_tile_index) ;  % Should be 27, always
    assert(raw_tile_count==27) ;
    raw_tile_index_from_raw_tile_index = (1:raw_tile_count)' ;
    is_present_from_raw_tile_index = isfinite(full_tile_index_from_raw_tile_index) ;
    raw_tile_index_from_tile_index = raw_tile_index_from_raw_tile_index(is_present_from_raw_tile_index) ;  
    assert(all(isfinite(raw_tile_index_from_tile_index))) ;  % There shouldn't be any nans in raw_tile_index_from_tile_index
    
    % Get the mapping from tile indices to full tile indices
    full_tile_index_from_tile_index = full_tile_index_from_raw_tile_index(is_present_from_raw_tile_index) ;
    
    % Invert raw_tile_index_from_tile_index
    tile_indexoid_from_raw_tile_index = invert_map_array(raw_tile_index_from_tile_index, raw_tile_count) ;    
    % tile_indexoid_from_raw_tile_index has zeros for missing raw tile indices,
    % want those to be nan's
    tile_index_from_raw_tile_index = tile_indexoid_from_raw_tile_index ;
    tile_index_from_raw_tile_index(tile_indexoid_from_raw_tile_index==0) = nan ;
    
    % Get mapping from tile_ijk1 to the tile index
    raw_tile_index_from_tile_ijk1 = reshape(raw_tile_index_from_raw_tile_index, [3 3 3]) ;
    tile_index_from_tile_ijk1 = tile_index_from_raw_tile_index(raw_tile_index_from_tile_ijk1) ;
    
    % Get the mapping from tile index to tile ijk1 (within the subset)
    full_tile_ijk1_from_tile_index = full_tile_ijk1_from_full_tile_index(full_tile_index_from_tile_index, :) ;
    offset_ijk = min(full_tile_ijk1_from_tile_index, [] , 1) ;
    tile_ijk1_from_tile_index = full_tile_ijk1_from_tile_index - offset_ijk + 1 ;

    % Get the xyz coordinate of each tile in the subset
    xyz_from_tile_index = xyz_from_full_tile_index(full_tile_index_from_tile_index,:) ;
    
    % Get the relative path of each tile in the subset
    relative_path_from_tile_index = relative_path_from_full_tile_index(full_tile_index_from_tile_index) ;
end
