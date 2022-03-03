function write_xlineshift_txt_in_place(input_folder_path, neurons_channel_tif_file_name, min_shift, max_shift, do_run_in_debug_mode)
    % Generate the Xlineshift.txt file      
    xlineshift_file_path = fullfile(input_folder_path, 'Xlineshift.txt') ;    
    
    % read image
    neurons_channel_tif_file_path = fullfile(input_folder_path, neurons_channel_tif_file_name) ;
    raw_stack = read_16bit_grayscale_tif(neurons_channel_tif_file_path) ;

    % Determine the optimal line-shift
    shift = determine_line_shift(raw_stack, min_shift, max_shift, do_run_in_debug_mode) ;

    % Write the Xlineshift.txt file
    write_xlineshift_file(xlineshift_file_path, shift) ; 
end
