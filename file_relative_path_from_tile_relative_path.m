function result = file_relative_path_from_tile_relative_path(relative_path, channel_index, label, extension) 
    % E.g. '2020-12-01/01/01916' -> '2020-12-01/01/01916/01916-ngc.0.tif'
    if ~exist('label', 'var') || isempty(label) ,
        extension = 'ngc' ;
    end       
    if ~exist('extension', 'var') || isempty(extension) ,
        extension = '.tif' ;
    end    
    [~, leaf_folder_name] = fileparts2(relative_path) ;
    imagery_file_name = sprintf('%s-%s.%d%s', leaf_folder_name, label, channel_index, extension) ;
    result = fullfile(relative_path, imagery_file_name) ;
end
