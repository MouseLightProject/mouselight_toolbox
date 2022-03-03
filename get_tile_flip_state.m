function flip_metadata = get_tile_flip_state(tile_path, sample_metadata)
    if sample_metadata.sample_metadata_version<=1 ,
        flip_metadata = struct() ;
        flip_metadata.is_x_flipped = sample_metadata.is_x_flipped ;
        flip_metadata.is_y_flipped = sample_metadata.is_y_flipped ;
    elseif sample_metadata.sample_metadata_version==2 ,
        xlineshift_file_path = fullfile(tile_path, 'Xlineshift.txt') ;
        if exist(xlineshift_file_path, 'file') ,
            % Tile is already line-shifted, which means it's also flipped on both axes
            flip_metadata = struct() ;
            flip_metadata.is_x_flipped = true ;
            flip_metadata.is_y_flipped = true ;
        else
            % Tile has not been line-shifted, so use the value from the sample metadata
            flip_metadata = struct() ;
            flip_metadata.is_x_flipped = sample_metadata.is_x_flipped ;
            flip_metadata.is_y_flipped = sample_metadata.is_y_flipped ;
        end
    else
        tile_metadata = read_tile_metadata(tile_path) ;
        flip_metadata = struct() ;
        flip_metadata.is_x_flipped = tile_metadata.is_x_flipped ;
        flip_metadata.is_y_flipped = tile_metadata.is_y_flipped ;        
    end        
end

