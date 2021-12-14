function [does_exist_from_tile_ijk1, ...
          tile_index_from_tile_ijk1, ...
          tile_ijk1_from_tile_index, ...
          raw_tile_ijk1_from_tile_index, ...
          relative_path_from_tile_index] = raw_tile_map_from_scopeloc(scopeloc)
    % Build a map/index of the raw tiles, given Erhan's scopeloc structure.
    %
    % On return:
    %   tile_ijk1_from_tile_index: a tile_count x 3 array giving the integral, one-based xyz position
    %                              of each tile.  Columns are in xyz order, tile index is
    %                              essentially arbitrary.  
    %   relative_path_from_tile_index: a tile_count x 1 cell array.  Each element
    %                                   contains the relative path of that tile.
    %                                   Tile indices are the same as in the
    %                                   ijk1_from_tile_index field.
    %   tile_index_from_tile_ijk1: a 3D array that maps from integer, one-based xyz
    %                              position to the tile index.  NaN for tiles
    %                              not present.
    
    relative_path_from_tile_index = scopeloc.relativepaths ;
    raw_tile_ijk1_from_tile_index = scopeloc.gridix(:,1:3) ;  % chop useless 4th column    
    tile_count = length(relative_path_from_tile_index) ;
    
    % Shift the lattice coordinates so the lowest one in the bounding cuboid is [1 1 1]
    min_raw_tile_ijk1 = min(raw_tile_ijk1_from_tile_index, [], 1) ;
    tile_ijk1_from_tile_index = raw_tile_ijk1_from_tile_index - min_raw_tile_ijk1 + 1 ;   
    
    % Make the 3d array of tile indices
    tile_lattice_shape = max(tile_ijk1_from_tile_index) ;
    tile_index_from_tile_ijk1 = nan(tile_lattice_shape) ;
    for tile_index = 1 : tile_count ,
        ijk1 = tile_ijk1_from_tile_index(tile_index,:) ;
        tile_index_from_tile_ijk1(ijk1(1), ijk1(2), ijk1(3)) = tile_index ;
    end
    
    % Make an array showing which tiles exist
    does_exist_from_tile_ijk1 = isfinite(tile_index_from_tile_ijk1) ;    
end
