function check_certs_after_verifying_thawing(input_root_folder_path, output_root_folder_path)
    % Makes sure there's a .similar-tif-exists for each .mj2 file in
    % input_root_folder_path.

    function result = check_single_cert_after_verifying_thawing_wrapper(root_folder_path, base_folder_relative_path, file_name, depth)  %#ok<INUSD> 
        result = check_single_cert_after_verifying_thawing(root_folder_path, base_folder_relative_path, file_name, output_root_folder_path) ;
    end

    find_and_verify(...
        input_root_folder_path, ...
        @does_file_name_end_in_dot_mj2, ...
        @check_single_cert_after_verifying_thawing_wrapper, ...
        @(varargin)(true)) ;
end
