function pointmatch(central_tile_landmark_folder_path, ...
                    other_tile_landmark_folder_path, ...
                    central_tile_raw_folder_path, ...
                    other_tile_raw_folder_path, ...
                    output_folder_name, ...
                    sample_metadata, ...
                    manual_nominal_other_tile_ijk_offset, ...
                    central_tile_ijk1, ...
                    maximum_landmark_count, ...
                    do_run_in_debug_mode)
    % Front-end function to do z point-matching in the Patrick pipeline.
    
    % Deal with arguments
    if ~exist('sample_metadata', 'var') || isempty(sample_metadata) ,
        sample_metadata = [] ;  % only used when in debug mode
    end
    if ~exist('manual_nominal_other_tile_ijk_offset', 'var') || isempty(manual_nominal_other_tile_ijk_offset) ,
        manual_nominal_other_tile_ijk_offset = [] ;  % Means to just calculate the nominal offset
    end
    if ~exist('central_tile_ijk1', 'var') || isempty(central_tile_ijk1) ,
        central_tile_ijk1 = [nan nan nan] ;  % only ever used for debugging, and currently not used at all
    end
    if ~exist('maximum_landmark_count', 'var') || isempty(maximum_landmark_count) ,
        maximum_landmark_count = 1e4 ;
    end   
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end   
    if do_run_in_debug_mode && isempty(sample_metadata) ,
        error('sample_metadata must be nonempty in debug mode') ;
    end
    
    % Read in stuff from input files
    central_tile_scope_struct = readScopeFile(central_tile_raw_folder_path) ;
    other_tile_scope_struct = readScopeFile(other_tile_raw_folder_path) ;
    
    central_tile_ijk_from_match_index_for_all_channels = zeros(0,3) ;
    other_tile_ijk_from_match_index_for_all_channels = zeros(0,3) ;
    for channel_index = 0:1 ,
        central_tile_ijk_and_descriptors_from_landmark_index = readDesc(central_tile_landmark_folder_path, channel_index) ;
        other_tile_ijk_and_descriptors_from_landmark_index = readDesc(other_tile_landmark_folder_path, channel_index) ;

        % Call the function that does the real work
        [match_struct, ...
         shift_axis_index, ...
         nominal_other_tile_offset_ijk, ...
         ijk_from_central_tile_border_landmark_index, ...
         ijk_from_other_tile_border_landmark_index] = ...
            pointmatch_core(central_tile_ijk_and_descriptors_from_landmark_index, ...
                            other_tile_ijk_and_descriptors_from_landmark_index, ...
                            central_tile_scope_struct, ...
                            other_tile_scope_struct, ...
                            manual_nominal_other_tile_ijk_offset, ...
                            maximum_landmark_count, ...
                            central_tile_ijk1) ;

        % Visualize matches
        if do_run_in_debug_mode ,
            central_tile_relative_path = tile_relative_path_from_tile_folder_path(central_tile_raw_folder_path) ;
            other_tile_relative_path = tile_relative_path_from_tile_folder_path(other_tile_raw_folder_path) ;
            visualize_z_matching_after_loading_stacks_and_flipping(...
                central_tile_raw_folder_path, ...
                other_tile_raw_folder_path, ...
                central_tile_ijk_and_descriptors_from_landmark_index, ...
                other_tile_ijk_and_descriptors_from_landmark_index, ...
                nominal_other_tile_offset_ijk, ...
                ijk_from_central_tile_border_landmark_index, ...
                ijk_from_other_tile_border_landmark_index, ...
                match_struct.X, ...
                match_struct.Y, ...
                channel_index, ...
                sample_metadata, ...
                central_tile_relative_path, ...
                other_tile_relative_path) ;
        end
                        
        % Write the main output file
        axis_letter_from_axis_index = 'XYZ';
        axis_letter = axis_letter_from_axis_index(shift_axis_index) ;
        ensure_folder_exists(output_folder_name) ;
        output_file_leaf_name = sprintf('channel-%d-match-%s.mat', channel_index, axis_letter) ;
        output_file_name = fullfile(output_folder_name, output_file_leaf_name) ;
        if exist(output_file_name,'file')
            unix(sprintf('rm -f %s',output_file_name)) ;
        end
        paireddescriptor = match_struct ;
        scopefile1 = central_tile_scope_struct ;
        scopefile2 = other_tile_scope_struct ;
        save(output_file_name, 'paireddescriptor', 'scopefile1', 'scopefile2') ;
        system(sprintf('chmod g+rw %s',output_file_name));

        % Save points for making the thumbnail
        central_tile_ijk_from_match_index_for_all_channels = vertcat(central_tile_ijk_from_match_index_for_all_channels, match_struct.X) ;  %#ok<AGROW>
        other_tile_ijk_from_match_index_for_all_channels = vertcat(other_tile_ijk_from_match_index_for_all_channels, match_struct.Y) ;  %#ok<AGROW>        
    end
    
    % Synthesize and write a thumbnail image file
    % x:R, y:G, z:B
    if isempty(central_tile_ijk_from_match_index_for_all_channels) ,
        col = [0 0 0] ;  % black as night
    else
        col = median(other_tile_ijk_from_match_index_for_all_channels-central_tile_ijk_from_match_index_for_all_channels,1) + 128 ;
    end    
    col = max(min(col,255),0);
    outpng = zeros(105,89,3);
    outpng(:,:,1) = col(1);
    outpng(:,:,2) = col(2);
    outpng(:,:,3) = col(3);
    thumbnail_image_file_name = fullfile(output_folder_name,'Thumbs.png') ;
    if exist(thumbnail_image_file_name,'file')
        system(sprintf('rm -f %s',thumbnail_image_file_name)) ;
    end
    imwrite(outpng,thumbnail_image_file_name)
    system(sprintf('chmod g+rw %s',thumbnail_image_file_name));
end
