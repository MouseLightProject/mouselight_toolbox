function copy_file_for_find_and_batch(tif_side_file_path, tif_root_folder_name, mj2_root_folder_name, varargin)
    relative_file_path_of_tif_side_file = relpath(tif_side_file_path, tif_root_folder_name) ;
    relative_file_path_of_mj2_side_file = relative_file_path_of_tif_side_file ;
    mj2_side_file_path = fullfile(mj2_root_folder_name, relative_file_path_of_mj2_side_file) ;
    mj2_side_folder_path = fileparts2(mj2_side_file_path) ;
    ensure_folder_exists(mj2_side_folder_path) ;
    copyfile(tif_side_file_path, mj2_side_file_path) ;                   
end
