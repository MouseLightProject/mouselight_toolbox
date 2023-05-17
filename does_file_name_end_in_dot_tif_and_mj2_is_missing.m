function result = does_file_name_end_in_dot_tif_and_mj2_is_missing(tif_file_path, tif_root_path, mj2_root_path, varargin)
    if does_file_name_end_in_dot_tif(tif_file_path) ,
        tif_relative_path = relpath(tif_file_path, tif_root_path) ;
        mj2_relative_path = replace_extension(tif_relative_path, '.mj2') ;
        mj2_file_path = fullfile(mj2_root_path, mj2_relative_path) ;
        is_mj2_file_present = logical(exist(mj2_file_path, 'file')) ;
        result = ~is_mj2_file_present ;
    else
        result = false ;
    end
end
