function result = tile_relative_path_from_tile_folder_path(tile_folder_path) 
    % E.g. '/foo/bar/baz/2020-12-01/01/01916' -> '2020-12-01/01/01916'
    [rest1, leaf_folder_name] = fileparts2(tile_folder_path) ;
    [rest2, leaf_folder_prefix] = fileparts2(rest1) ;
    [~, tile_date] = fileparts2(rest2) ;
    result = fullfile(tile_date, leaf_folder_prefix, leaf_folder_name) ;
end
