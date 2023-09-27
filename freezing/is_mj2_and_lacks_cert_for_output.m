function result = is_mj2_and_lacks_cert_for_output(input_file_path, input_root_path, output_root_path)
    is_input_file_an_mj2 = does_file_name_end_in_dot_mj2(input_file_path) ;
    if ~is_input_file_an_mj2 ,
        result = false ;
        return
    end
%     % Check to see if the output is present
%     relative_input_file_path = relpath(input_file_path, input_root_path) ;
%     relative_output_file_path = replace_extension(relative_input_file_path, '.tif') ;
%     output_file_path = fullfile(output_root_path, relative_output_file_path) ;
%     does_output_file_exist = logical(exist(output_file_path, 'file')) ;
%     if ~does_output_file_exist ,
%         result = true ;
%         return
%     end
    does_cert_exist = does_is_similar_to_mj2_check_file_exist(input_file_path, input_root_path, output_root_path) ;
    result = ~does_cert_exist ;
end
