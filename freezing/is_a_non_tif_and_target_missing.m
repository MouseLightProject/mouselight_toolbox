function result = is_a_non_tif_and_target_missing(tif_side_file_path, tif_root_path, mj2_root_path, varargin)
    [~, file_name] = fileparts2(tif_side_file_path) ;
    is_true_so_far = ~does_file_name_end_in_dot_tif(file_name) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    % Check to see if the target is missing
    relative_file_path_of_tif_side_file = relpath(tif_side_file_path, tif_root_path) ;
    relative_file_path_of_mj2_side_file = relative_file_path_of_tif_side_file ;
    mj2_side_file_path = fullfile(mj2_root_path, relative_file_path_of_mj2_side_file) ;
    result = ~exist(mj2_side_file_path, 'file') ;
end
