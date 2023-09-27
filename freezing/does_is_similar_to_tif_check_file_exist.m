function result = does_is_similar_to_tif_check_file_exist(tif_file_path, tif_root_path, mj2_root_path)
    tif_relative_path = relpath(tif_file_path, tif_root_path) ;
    mj2_relative_path = replace_extension(tif_relative_path, '.mj2') ;
    mj2_file_path = fullfile(mj2_root_path, mj2_relative_path) ;
    check_file_path = horzcat(mj2_file_path, '.is-similar-to-tif') ;
    result = logical(exist(check_file_path, 'file')) ;
end
