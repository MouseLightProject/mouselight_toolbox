function result = read_sample_metadata_robustly(tile_folder_path)    
    try 
        result = read_sample_metadata_file(tile_folder_path) ;
    catch me        
        if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,            
            try
                [neuron_channel_index, background_channel_index] = read_channel_semantics_file(tile_folder_path) ;
                % For older samples, both dims were always flipped
                result = ...
                    struct('neuron_channel_index', {neuron_channel_index}, ...
                           'background_channel_index', {background_channel_index}, ...
                           'is_x_flipped', true, ...
                           'is_y_flipped', true) ;
            catch me
                if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,
                    % No sample metadata, so use defaults
                    result = ...
                        struct('neuron_channel_index', {0}, ...
                               'background_channel_index', {1}, ...
                               'is_x_flipped', true, ...
                               'is_y_flipped', true) ;
                    warning('Unable to find sample metadata, using default settings') ;       
                else
                    rethrow(me) ;
                end
            end
        else
            rethrow(me) ;
        end
    end
end
