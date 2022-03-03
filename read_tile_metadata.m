function result = read_tile_metadata(tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    tile_metadata_file_path = fullfile(tile_folder_path, 'tile-metadata.txt') ;
    result = read_metadata_file(tile_metadata_file_path) ;
end
