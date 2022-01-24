function result = file_path_from_tile_path(tile_path, channel_index, label, extension) 
    % E.g. '2020-12-01/01/01916' -> '2020-12-01/01/01916/01916-ngc.0.tif'
    % Also works if the input path is the absolute path to a tile.
    if ~exist('label', 'var') || isempty(label) ,
        label = 'ngc' ;
    end       
    if ~exist('extension', 'var') || isempty(extension) ,
        extension = '.tif' ;
    end    
    [~, leaf_folder_name] = fileparts2(tile_path) ;
    imagery_file_name = sprintf('%s-%s.%d%s', leaf_folder_name, label, channel_index, extension) ;
    result = fullfile(tile_path, imagery_file_name) ;
end
