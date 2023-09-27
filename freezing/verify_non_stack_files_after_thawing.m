function verify_non_stack_files_after_thawing(output_root_folder_path, input_root_folder_path)
    % Makes sure all the output files are present in the the destination, and have
    % the same size and md5sum.
    
    function result = verify_single_non_stack_file_wrapper(input_root_folder_path, base_folder_relative_path, file_name, depth)  %#ok<INUSD> 
        result = verify_single_non_stack_file(input_root_folder_path, base_folder_relative_path, file_name, output_root_folder_path) ;
    end

    find_and_verify(input_root_folder_path, ...
                    @does_file_name_not_end_in_dot_mj2, ...
                    @verify_single_non_stack_file_wrapper, ...
                    @(varargin)(true)) ;
end
