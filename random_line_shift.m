function random_line_shift(input_root_folder, tile_relative_path, output_root_folder, do_force_computation)
    % Deal with args
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end

    % Set some internal parmeters
    min_shift = -9 ;
    max_shift = +9 ;
    channel_count = 2 ;
        
    % Construct absolute paths to input, output folder for this tile
    input_folder_path = fullfile(input_root_folder, tile_relative_path) ;
    output_folder_path = fullfile(output_root_folder, tile_relative_path) ;
    [~, tile_base_name] = fileparts2(tile_relative_path) ;
    
    % Get the file paths for the output files
    synthetic_xlineshift_file_path = fullfile(output_folder_path, 'synthetic-Xlineshift.txt') ;
    zero_based_channel_index_from_channel_index = (1:channel_count)-1 ;
    tif_file_names = ...
        arrayfun(@(index)([tile_base_name '-ngc.' num2str(index) '.tif']), ...
                 zero_based_channel_index_from_channel_index, ...
                 'UniformOutput', false) ;
    output_file_path_from_tif_index = cellfun(@(tif_file_name)(fullfile(output_folder_path, tif_file_name)), ...
                                              tif_file_names, ...
                                              'UniformOutput', false) ;

    % Read or generate the Xlineshift.txt file                                          
    if exist(synthetic_xlineshift_file_path, 'file') && ~do_force_computation,
        shift = read_xlineshift_file(synthetic_xlineshift_file_path) ;
    else
        % Synthesize a line-shift
        shift = max(min_shift, min(round(normrnd(0,1)), max_shift)) ;
        
        % Make sure the output folder exists
        ensure_folder_exists(output_folder_path) ;

        % Write the Xlineshift.txt file
        write_xlineshift_file(synthetic_xlineshift_file_path, shift) ; 
    end

    % Write the line-shifted tif stacks
    input_file_path_from_tif_index = cellfun(@(tif_file_name)(fullfile(input_folder_path, tif_file_name)), ...
                                             tif_file_names, ...
                                             'UniformOutput', false) ;                                         
    tif_count = length(tif_file_names) ;
    for tif_index = 1 : tif_count ,
        input_tif_file_path = input_file_path_from_tif_index{tif_index} ;
        output_tif_file_path = output_file_path_from_tif_index{tif_index} ;
        if ~exist(output_tif_file_path, 'file')  || do_force_computation ,
            stack = read_16bit_grayscale_tif(input_tif_file_path) ;
            stack(2:2:end,:,:)  = circshift(stack(2:2:end,:,:), shift, 2) ;
                % shift every other y level, starting with the second, by shift voxels, in x
            % Don't need to do any flips, want to leave as-is
            % And line-fix-shifting always happens before flip-normalization when fixing
            % line-shift
            write_16bit_grayscale_tif(output_tif_file_path, stack) ;
        end
    end
end
