function result = does_is_similar_to_mj2_check_file_exist(tif_file_path, mj2_root_path, tif_root_path)
    mj2_relative_path = relpath(tif_file_path, mj2_root_path) ;
    tif_relative_path = replace_extension(mj2_relative_path, '.tif') ;
    tif_file_path = fullfile(tif_root_path, tif_relative_path) ;
    check_file_path = horzcat(tif_file_path, '.is-similar-to-mj2') ;
    result = logical(exist(check_file_path, 'file')) ;
end
