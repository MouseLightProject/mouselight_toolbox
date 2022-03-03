function [result, state_count, tif_file_names, original_tif_file_names, shifted_tif_file_names] = ...
        determine_fix_line_shift_tile_state(input_root_folder, tile_relative_path, channel_count)
    % Construct absolute paths to input folder for this tile
    input_folder_path = fullfile(input_root_folder, tile_relative_path) ;
    [~, tile_base_name] = fileparts2(tile_relative_path) ;
    
    % Generate the names of the tif files
    zero_based_channel_index_from_channel_index = (1:channel_count)-1 ;
    tif_file_names = ...
        arrayfun(@(index)([tile_base_name '-ngc.' num2str(index) '.tif']), ...
                 zero_based_channel_index_from_channel_index, ...
                 'UniformOutput', false) ;
    original_tif_file_names = ...
        arrayfun(@(index)([tile_base_name '-ngc.' num2str(index) '.original.tif']), ...
                 zero_based_channel_index_from_channel_index, ...
                 'UniformOutput', false) ;
    shifted_tif_file_names = ...
        arrayfun(@(index)([tile_base_name '-ngc.' num2str(index) '.shifted.tif']), ...
                 zero_based_channel_index_from_channel_index, ...
                 'UniformOutput', false) ;
    
    % Generate a list of all the files we need to worry about
    name_from_file_index = [ tif_file_names, original_tif_file_names, {'Xlineshift.txt'}, shifted_tif_file_names, {'tile-metadata.txt'} ] ;
           
    % Need to build a state_count x file_count matrix, with
    % +1 for all files that must be present at that state
    % -1 for all files that must be absent at that state
    % 0 for all files that might be present or might be absent at that state
    file_count = length(name_from_file_index) ;
    state_count = 6 ;
    file_sign_from_state_index_from_file_index = zeros(state_count, file_count) ;
    % The initial state, with ddddd-ngc.0.tif, ddddd-ngc.1.tif, and nothing else
    file_sign_from_state_index_from_file_index(1,:) = ...
        [ repmat(+1, [1 channel_count]) repmat(-1, [1 channel_count]) -1 repmat(-1, [1 channel_count]) -1 ] ; %#ok<REPMAT>
    file_sign_from_state_index_from_file_index(2,:) = ...
        [ repmat(-1, [1 channel_count]) repmat(+1, [1 channel_count]) -1 repmat(-1, [1 channel_count]) -1 ] ; %#ok<REPMAT>
    file_sign_from_state_index_from_file_index(3,:) = ...
        [ repmat(-1, [1 channel_count]) repmat(+1, [1 channel_count]) +1 repmat(-1, [1 channel_count]) -1 ] ; %#ok<REPMAT>
    file_sign_from_state_index_from_file_index(4,:) = ...
        [ repmat(-1, [1 channel_count]) repmat(+1, [1 channel_count]) +1 repmat(+1, [1 channel_count]) +1 ] ; %#ok<REPMAT>
    file_sign_from_state_index_from_file_index(5,:) = ...
        [ repmat(+1, [1 channel_count]) repmat(+1, [1 channel_count]) +1 repmat(-1, [1 channel_count]) +1 ] ; %#ok<REPMAT>
    file_sign_from_state_index_from_file_index(6,:) = ...
        [ repmat(+1, [1 channel_count]) repmat(-1, [1 channel_count]) -1 repmat(-1, [1 channel_count]) +1 ] ; %#ok<REPMAT>
    
    % Derive the matrices that indicate which files must exist vs cant exist
    must_exist_from_state_index_from_file_index = ( file_sign_from_state_index_from_file_index > 0 ) ;
    cant_exist_from_state_index_from_file_index = ( file_sign_from_state_index_from_file_index < 0 ) ;
    
    % Determine which files exist
    does_exist_from_file_index = cellfun(@(file_name)(exist(fullfile(input_folder_path, file_name), 'file')), name_from_file_index) ;
    is_missing_from_file_index = ~does_exist_from_file_index ;
    
    % Determine what states we could be in 
    is_possible_from_state_index = ...
        all(~must_exist_from_state_index_from_file_index | does_exist_from_file_index,2) & ...
        all(~cant_exist_from_state_index_from_file_index | is_missing_from_file_index,2) ;
    
    % If can't determine a unique state, just error out---don't try to be clever
    possible_state_count = sum(is_possible_from_state_index) ;
    if possible_state_count == 0 ,
        error('Can''t determine state for tile %s. All possible states ruled out.', tile_relative_path) ;
    elseif possible_state_count == 1 ,
        % no nothing, this is what we want
    else
        state_index_from_possible_state_index = find(is_possible_from_state_index) ;
        error('Can''t determine unique state for tile %s. Possible states are: %s', tile_relative_path, mat2str(state_index_from_possible_state_index)) ;
    end
    
    % Extract the current state index
    result = find(is_possible_from_state_index) ;
end
