function advance_state_for_fix_line_shift_in_place(input_root_folder, tile_relative_path, do_run_in_debug_mode, ...
                                                   min_shift, max_shift, ...
                                                   tif_file_name_from_channel_index, original_tif_file_name_from_channel_index, shifted_tif_file_name_from_channel_index, ...
                                                   neuron_channel_index0, original_is_x_flipped, original_is_y_flipped, ...
                                                   state_index)
    input_folder_path = fullfile(input_root_folder, tile_relative_path) ;                                               
    
    function rename(old_file_name, new_file_name)
        tif_file_path = fullfile(input_folder_path, old_file_name) ;
        original_tif_file_path = fullfile(input_folder_path, new_file_name) ;
        system_from_list_with_error_handling({'mv', '-T', tif_file_path, original_tif_file_path}) ;
    end

    function delete_file(file_name)
        file_path = fullfile(input_folder_path, file_name) ;
        system_from_list_with_error_handling({'rm', '-f', file_path}) ;
    end

    if state_index==1 ,
        % Rename ddddd-ngc.0.tif to dddd-ngc.0.original.tif
        cellfun(@rename, tif_file_name_from_channel_index, original_tif_file_name_from_channel_index) ;
    elseif state_index==2 ,
        % Run the line-shift code and output Xlineshift.txt
        neuron_channel_index = neuron_channel_index0 + 1 ;
        neurons_channel_tif_file_name = original_tif_file_name_from_channel_index{neuron_channel_index} ;
        write_xlineshift_txt_in_place(input_folder_path, neurons_channel_tif_file_name, min_shift, max_shift, do_run_in_debug_mode) ;
    elseif state_index==3 ,
        % Generate the line-shifted and (possibly) flipped stacks, and the
        % tile-metadata.txt file
        write_line_shifted_stacks_and_tile_metadata_in_place(input_folder_path, ...
                                                             original_tif_file_name_from_channel_index, ...
                                                             shifted_tif_file_name_from_channel_index, ...
                                                             original_is_x_flipped, ...
                                                             original_is_y_flipped)
    elseif state_index==4 ,
        % Rename ddddd-ngc.0.shifted.tif to dddd-ngc.0.tif
        cellfun(@rename, shifted_tif_file_name_from_channel_index, tif_file_name_from_channel_index) ;
    elseif state_index==5 ,
        % Delete the original stacks
        cellfun(@delete_file, original_tif_file_name_from_channel_index) ;        
        % Delete Xlineshift.txt
        delete_file('Xlineshift.txt') ;
    elseif state_index==6 ,
        % this is the final state, nothing to do
    else
        error('Illegal state index: %g', state_index) ;
    end
end
