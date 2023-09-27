function result = is_leaf_mj2_and_lacks_either_output_or_cert(input_file_path, input_root_path, output_root_path)
    is_input_file_an_input_leaf_image = is_a_mj2_in_a_folder_with_no_subfolders(input_file_path) ;
    if ~is_input_file_an_input_leaf_image ,
        result = false ;
        return
    end
    % Check to see if the output is present
    relative_input_file_path = relpath(input_file_path, input_root_path) ;
    relative_output_file_path = replace_extension(relative_input_file_path, '.tif') ;
    output_file_path = fullfile(output_root_path, relative_output_file_path) ;
    does_output_file_exist = logical(exist(output_file_path, 'file')) ;
    if ~does_output_file_exist ,
        result = true ;
        return
    end
    % If get here, input file is a leaf image, and the output file is present
    % Check for certificate  
    does_cert_exist = does_is_similar_to_tif_check_file_exist(input_file_path, input_root_path, output_root_path) ;
    result = 
end
