function write_line_shifted_stacks_and_tile_metadata_in_place(tile_folder_path, ...
                                                              original_tif_file_name_from_channel_index, ...
                                                              shifted_tif_file_name_from_channel_index, ...
                                                              original_is_x_flipped, ...
                                                              original_is_y_flipped)
    % Generate the line-shifted and (possibly) flipped stacks, and the
    % tile-metadata.txt file.
    xlineshift_file_path = fullfile(tile_folder_path, 'Xlineshift.txt') ;
    shift = read_xlineshift_file(xlineshift_file_path) ;
    
    % Write the line-shifted tif stacks
    channel_count = length(original_tif_file_name_from_channel_index) ;
    for channel_index = 1 : channel_count ,
        input_tif_file_name = original_tif_file_name_from_channel_index{channel_index} ;
        input_tif_file_path = fullfile(tile_folder_path, input_tif_file_name) ;
        output_tif_file_name = shifted_tif_file_name_from_channel_index{channel_index} ;
        output_tif_file_path = fullfile(tile_folder_path, output_tif_file_name) ;
        stack = read_16bit_grayscale_tif(input_tif_file_path) ;
        stack(2:2:end,:,:)  = circshift(stack(2:2:end,:,:), shift, 2) ;
            % shift every other y level, starting with the second, by shift voxels, in x
        % Apply any needed flips---want the output to be flipped in x and y, since
        % that's what the rest of the pipeline expects
        if original_is_x_flipped ,
            % do nothing, this is how we want it
        else
            stack = fliplr(stack) ;                
        end
        if original_is_y_flipped ,
            % do nothing, this is how we want it
        else
            stack = flipud(stack) ;                
        end
        write_16bit_grayscale_tif(output_tif_file_path, stack) ;
    end
    
    % Write the tile metadate file
    tile_metadata_file_path = fullfile(tile_folder_path, 'tile-metadata.txt') ;
    is_x_flipped = true ;
    is_y_flipped = true ;    
    write_tile_metadata(tile_metadata_file_path, shift, is_x_flipped, is_y_flipped) ;
end
