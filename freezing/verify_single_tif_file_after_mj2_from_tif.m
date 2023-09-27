function result = verify_single_tif_file_after_mj2_from_tif(tif_root_folder_path, tif_folder_relative_path, tif_file_name, mj2_root_folder_path)  %#ok<INUSD> 
    file_name_of_mj2 = replace_extension(tif_file_name, '.mj2') ;
    mj2_file_path = fullfile(mj2_root_folder_path, tif_folder_relative_path, file_name_of_mj2) ;
    check_file_path = horzcat(mj2_file_path, '.is-similar-to-tif') ;    
    result = logical( exist(check_file_path, 'file') ) ;
end
