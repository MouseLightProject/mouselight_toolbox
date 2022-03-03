function result = read_old_style_sample_metadata(raw_tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    % This is using a style of sample-metadatathat we used only before about 2022-02
    % It includes the x- and y- flipping, which after that point we always
    % regularized.
    sample_metadata_file_path = fullfile(raw_tile_folder_path, 'sample-metadata.txt') ;
    result = read_metadata_file(sample_metadata_file_path) ;
end
