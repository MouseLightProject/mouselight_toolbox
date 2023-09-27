function verify_non_stack_files_after_freezing(mj2_root_folder_path, tif_root_folder_path)
    % Makes sure all the target files are present in the the destination, and have
    % the right size, or at least a plausible size in the case of .mj2's.
    
    function result = verify_single_non_stack_file_wrapper(tif_root_folder_path, tif_folder_relative_path, tif_file_name, depth)  %#ok<INUSD> 
        result = verify_single_non_stack_file(tif_root_folder_path, tif_folder_relative_path, tif_file_name, mj2_root_folder_path) ;
    end
    
    find_and_verify(tif_root_folder_path, ...
                    @does_file_name_not_end_in_dot_tif, ...
                    @verify_single_non_stack_file_wrapper, ...
                    @is_not_the_ktx_folder) ;
end
