function result = is_a_mj2_in_a_folder_with_no_subfolders_and_target_missing(input_file_path, input_root_path, output_root_path, varargin)
    is_true_so_far = is_a_mj2_in_a_folder_with_no_subfolders(input_file_path) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    % Check to see if the target is missing
    relative_file_path_of_input = relpath(input_file_path, input_root_path) ;
    relative_file_path_of_output= replace_extension(relative_file_path_of_input, '.tif') ;
    output_file_path = fullfile(output_root_path, relative_file_path_of_output) ;
    result = ~logical(exist(output_file_path, 'file')) ;
end
