function result = read_sample_metadata_robustly(tile_folder_path)    
    % Read the sample metadata for the sample at tile_folder_path in a way that is
    % (hopefully) robust.  We first try to read post-line-fix-sample-metadata.txt.
    % If that's present, we parse it and return the metadata in a struct. If that's
    % missing, we check for original-sample-metadata.txt.  If that's present, it
    % means the sample is from after we started doing in-place line-fixing, but has
    % not been line-fixed, so we error out. Next, we first try to read the old-style
    % sample metadata folder named 'sample-metadata.txt', and if we find it we parse
    % it and return the metadata. Next, we try to read the (even-older-style)
    % 'channel-semantics.txt' file.  If even that fails, we use a set of fallback
    % values that should work for older samples created before we started using
    % channel-semantics.txt or sample-metadata.txt.
    %
    % The metadata returned from this function is tagged with the version of metadata found.
    % Versions:
    %   0: No sample metadata files found, metadata returned is the default values
    %      from before we started using sample metadata files.
    %   1: Sample metadata is from a 'channel-semantics.txt' file.  This file only
    %      contains the neuron/background channel.  The is_x_flipped and
    %      is_y_flipped values are inferred, since all samples of this vintage were
    %      flipped in both.
    %   2: Sample metadata is from a 'sample-metadata.txt' file.  
    %      Note that one issue with samples of this vintage is that you need to look at
    %      the tiles, and look for the Xlineshift.txt file, to figure out if they've been
    %      line-shifted or not.  If they've been line-shifted, they will be normalized
    %      such that they are flipped in both x and y, relative to how they're shown in
    %      Horta 2D.  If they haven't been line-shifted, then you need to consult the
    %      sample metadata to see whether the tiles are flipped in x and/or y.
    %   3: Sample metadata is from a 'post-line-fix-sample-metadata.txt' file.  
    %      In this case, the sample metadata returned does not have the is_x_flipped
    %      or is_y_flipped fields.  Consult the tile metadata to determine the flip
    %      state of the tile.
    
    % See if post-line-fix-sample-metadata.txt is present.  If do, read and return
    % it.
    try 
        post_line_fix_sample_metadata = read_post_line_fix_sample_metadata(tile_folder_path) ;
        result = add_fields(post_line_fix_sample_metadata, 'sample_metadata_version', 3) ;        
        return
    catch me        
        if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,
            % do nothing, proceed
        else
            rethrow(me) ;
        end
    end

    % See if original-sample-metadata.txt is present, if it is, exit with an error.    
    try
        original_sample_metadata = read_original_sample_metadata(tile_folder_path) ;
    catch me
        if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,
            % "Return" the exception as the original sample metadata
            original_sample_metadata = me ;
        else
            rethrow(me) ;
        end
    end
    if isstruct(original_sample_metadata) ,
        % If get here, post-line-fix-sample-metadata.txt is missing, but
        % original-sample-metadata.txt is present.
        error('Sample is of a vintage that needs to be in-place line-fixed before processing can proceed') ;
    end
    
    % If get here, post-line-fix-sample-metadata.txt is missing, and so is
    % original-sample-metadata.txt.    
    
    % Try to read an old-style sample-metadata.txt file
    try
        old_style_sample_metadata = read_old_style_sample_metadata(tile_folder_path) ;
        result = add_fields(old_style_sample_metadata, 'sample_metadata_version', 2) ;        
        return
    catch me
        if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,
            % do nothing, proceed
        else
            rethrow(me) ;
        end
    end    
    
    % Try to read an even-older-style channel_semantics.txt file
    try
        [neuron_channel_index, background_channel_index] = read_channel_semantics_file(tile_folder_path) ;
        % For older samples, both dims were always flipped
        result = ...
            struct('neuron_channel_index', {neuron_channel_index}, ...
                   'background_channel_index', {background_channel_index}, ...
                   'is_x_flipped', true, ...
                   'is_y_flipped', true, ...
                   'sample_metadata_version', 1) ;
        return
    catch me
        if strcmp(me.identifier, 'read_file_into_cell_string:unable_to_open_file') ,
            % do nothing, proceed
        else
            rethrow(me) ;
        end
    end     
    
    % No sample metadata, so use defaults
    result = ...
        struct('neuron_channel_index', {0}, ...
               'background_channel_index', {1}, ...
               'is_x_flipped', true, ...
               'is_y_flipped', true, ...
               'sample_metadata_version', 0) ;
end
