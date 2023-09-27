function mj2_from_tif_single_for_find_and_batch(tif_file_path, tif_root_folder_name, mj2_root_folder_name, compression_ratio)
    % Compress a single .tif to .mj2
    relative_file_path_of_tif = relpath(tif_file_path, tif_root_folder_name) ;
    relative_file_path_of_mj2 = replace_extension(relative_file_path_of_tif, '.mj2') ;
    mj2_file_path = fullfile(mj2_root_folder_name, relative_file_path_of_mj2) ;
    mj2_folder_path = fileparts2(mj2_file_path) ;
    ensure_folder_exists(mj2_folder_path) ;
    mj2_from_tif_single(mj2_file_path, tif_file_path, compression_ratio) ;
end
