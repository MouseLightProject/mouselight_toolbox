function result = is_a_tif_in_a_folder_with_no_subfolders_and_target_missing(tif_file_path, tif_root_path, mj2_root_path, varargin)
    is_true_so_far = is_a_tif_in_a_folder_with_no_subfolders(tif_file_path) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    % Check to see if the target is missing
    relative_file_path_of_tif = relpath(tif_file_path, tif_root_path) ;
    relative_file_path_of_mj2 = replace_extension(relative_file_path_of_tif, '.mj2') ;
    mj2_file_path = fullfile(mj2_root_path, relative_file_path_of_mj2) ;
    result = ~logical(exist(mj2_file_path, 'file')) ;
end
