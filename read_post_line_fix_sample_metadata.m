function result = read_post_line_fix_sample_metadata(raw_tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    sample_metadata_file_path = fullfile(raw_tile_folder_path, 'post-line-fix-sample-metadata.txt') ;
    result = read_metadata_file(sample_metadata_file_path) ;
end
