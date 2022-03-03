function result = read_original_sample_metadata(raw_tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    sample_metadata_file_path = fullfile(raw_tile_folder_path, 'original-sample-metadata.txt') ;
    result = read_metadata_file(sample_metadata_file_path) ;
end
