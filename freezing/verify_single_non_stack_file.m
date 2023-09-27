function result = verify_single_non_stack_file(input_root_folder_path, input_base_folder_relative_path, input_file_name, output_root_folder_path)
    % Compare the md5sums of the two files
    input_file_path = fullfile(input_root_folder_path, input_base_folder_relative_path, input_file_name) ;
    output_file_path = fullfile(output_root_folder_path, input_base_folder_relative_path, input_file_name) ;
    if exist(output_file_path, 'file') ,                    
        result = are_files_same_size_and_md5sum(input_file_path, output_file_path) ;
    else
        result = false ;
    end
end
