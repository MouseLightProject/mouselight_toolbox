function result = is_a_non_mj2_and_target_missing(input_file_path, input_root_path, output_root_path, varargin)
    [~, input_file_name] = fileparts2(input_file_path) ;
    is_true_so_far = ~does_file_name_end_in_dot_mj2(input_file_name) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    % Check to see if the target is missing
    relative_file_path_of_input_file = relpath(input_file_path, input_root_path) ;
    relative_file_path_of_output_file = relative_file_path_of_input_file ;
    output_file_path = fullfile(output_root_path, relative_file_path_of_output_file) ;
    result = ~exist(output_file_path, 'file') ;
end
