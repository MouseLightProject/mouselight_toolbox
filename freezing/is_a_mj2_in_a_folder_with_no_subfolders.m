function result = is_a_mj2_in_a_folder_with_no_subfolders(input_file_path, varargin)
    [input_folder_path, input_file_name] = fileparts2(input_file_path) ;
    is_true_so_far = does_file_name_end_in_dot_mj2(input_file_name) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    result = ~does_folder_have_subfolders(input_folder_path) ;
end
