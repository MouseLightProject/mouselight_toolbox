function tif_from_mj2_single_for_find_and_batch(input_file_path, input_root_folder_name, output_root_folder_name)
    % Decompress a single .mj2 to .tif
    relative_input_file_path = relpath(input_file_path, input_root_folder_name) ;
    relative_output_file_path = replace_extension(relative_input_file_path, '.tif') ;
    output_file_path = fullfile(output_root_folder_name, relative_output_file_path) ;
    output_folder_path = fileparts2(output_file_path) ;
    ensure_folder_exists(output_folder_path) ;
    tif_from_mj2_single(output_file_path, input_file_path) ;
end
