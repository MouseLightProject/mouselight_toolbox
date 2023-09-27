function result = check_single_cert_after_verifying_thawing(...
        input_root_folder_path, input_folder_relative_path, input_file_name, output_root_folder_path)  %#ok<INUSD> 
    output_file_name = replace_extension(input_file_name, '.tif') ;
    output_file_path = fullfile(output_root_folder_path, input_folder_relative_path, output_file_name) ;
    cert_file_path = horzcat(output_file_path, '.is-similar-to-mj2') ;    
    result = logical( exist(cert_file_path, 'file') ) ;
end
