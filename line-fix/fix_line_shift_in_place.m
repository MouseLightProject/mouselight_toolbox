function fix_line_shift_in_place(input_root_folder, tile_relative_path, original_sample_metadata, do_run_in_debug_mode)
    % Deal with args
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end

    % Set some internal parmeters
    channel_count = 2 ;
    min_shift = -9 ;
    max_shift = +9 ;
    
    % Figure out which channel we'll use to compute the line shift
    neuron_channel_index0 = original_sample_metadata.neuron_channel_index ;
    original_is_x_flipped = original_sample_metadata.is_x_flipped ;
    original_is_y_flipped = original_sample_metadata.is_y_flipped ;
    
    % Determine the current state by probing the file system
    [initial_state_index, state_count, tif_file_names, original_tif_file_names, shifted_tif_file_names] = ...
        determine_fix_line_shift_tile_state(input_root_folder, tile_relative_path, channel_count) ;
    
    % Try to advance from the current state to the done state
    for state_index = initial_state_index : (state_count-1) ,
        advance_state_for_fix_line_shift_in_place(input_root_folder, tile_relative_path, do_run_in_debug_mode, ...
                                                  min_shift, max_shift, ...
                                                  tif_file_names, original_tif_file_names, shifted_tif_file_names, ...
                                                  neuron_channel_index0, original_is_x_flipped, original_is_y_flipped, ...
                                                  state_index) ;
    end
    % If get here without error, that must have worked    
end

