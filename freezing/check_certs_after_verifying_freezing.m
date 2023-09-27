function check_certs_after_verifying_freezing(tif_root_folder_path, mj2_root_folder_path)
    % Makes sure there's a .similar-mj2-exists for each .tif file in
    % tif_root_folder_path.

    function result = verify_single_tif_file_after_mj2_from_tif_wrapper(tif_root_folder_path, tif_folder_relative_path, tif_file_name, depth)  %#ok<INUSD> 
        result = verify_single_tif_file_after_mj2_from_tif(tif_root_folder_path, tif_folder_relative_path, tif_file_name, mj2_root_folder_path) ;
    end

    find_and_verify(...
        tif_root_folder_path, ...
        @does_file_name_end_in_dot_tif, ...
        @verify_single_tif_file_after_mj2_from_tif_wrapper, ...
        @is_not_the_ktx_folder) ;
end
