function check_some_tiles(sample_date_as_string, relative_path_from_subset_tile_index, do_show_progress)
    if ~exist('do_show_progress', 'var') || isempty(do_show_progress) ,
        do_show_progress = false ;
    end
    
    % Determine where the raw tiles are
    raw_tile_root_path_template = '/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling' ;
    raw_tile_root_path = sprintf(raw_tile_root_path_template, sample_date_as_string) ;
    % Sometimes they use a "Tiling" folder, sometimes not...
    if ~exist(raw_tile_root_path, 'file') ,
        raw_tile_root_path_template = '/groups/mousebrainmicro/mousebrainmicro/data/acquisition/%s' ;
        raw_tile_root_path = sprintf(raw_tile_root_path_template, sample_date_as_string) ;
    end
    
    % Build the tile index
    sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date_as_string) ;    
    tile_index = compute_or_read_from_memo(sample_memo_folder_path, ...
                                               'raw-tile-index', ...
                                               @()(build_raw_tile_index(raw_tile_root_path)), ...
                                               false) ;
    tile_index_from_tile_ijk1 = tile_index.tile_index_from_tile_ijk1 ;
    ijk1_from_tile_index = tile_index.ijk1_from_tile_index ;
    %xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
    relative_path_from_tile_index = tile_index.relative_path_from_tile_index ;
    raw_tile_map_shape = size(tile_index_from_tile_ijk1)
    raw_tile_count = length(relative_path_from_tile_index) ;
    
    % Report the number of tiles
    fprintf('Raw tile folder count: %d\n', raw_tile_count) ;
    if raw_tile_count==0 ,
        error('There are no raw tiles!') ;
    end

    % Find the tiles to be checked within the tile index
    [is_in_tile_index_from_subset_tile_index, tile_index_from_subset_tile_index] = ...
        ismember(relative_path_from_subset_tile_index, relative_path_from_tile_index) ;    
    if ~all(is_in_tile_index_from_subset_tile_index) ,
        error('Some subset tiles do not seem to be in the tile index') ;
    end
    subset_tile_count = length(relative_path_from_subset_tile_index)
    
    % Paths to all the pipeline outputs
    pipeline_output_folder_path_template_from_stage_index = {raw_tile_root_path_template, ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output'} ;
    stage_name_from_index = {'raw', 'line-fix', 'classifier', 'descriptor', 'point-match'} ;    
    
    % Get the tile shape, size for the raw tiles
    first_raw_tile_folder_relative_path = relative_path_from_tile_index{1} ;
    [~,first_raw_tile_folder_leaf_name] = fileparts2(first_raw_tile_folder_relative_path) ;
    first_raw_tile_channel_0_file_relative_path = fullfile(first_raw_tile_folder_relative_path, sprintf('%s-ngc.0.tif', first_raw_tile_folder_leaf_name)) ;
    first_raw_tile_channel_0_file_absolute_path = fullfile(raw_tile_root_path, first_raw_tile_channel_0_file_relative_path) ;
    stack = read_16bit_grayscale_tif(first_raw_tile_channel_0_file_absolute_path) ;
    nominal_tile_shape_yxz = size(stack) ;
    nominal_raw_tif_file_size = get_file_size(first_raw_tile_channel_0_file_absolute_path) ;
    fprintf('Nominal tile shape (yxz) is: [%d %d %d]\n', nominal_tile_shape_yxz) ;
    fprintf('Nominal raw tiff file size is: %d\n', nominal_raw_tif_file_size) ;

    % Get the tile size for the line-fixed files
    line_fix_folder_path = sprintf(pipeline_output_folder_path_template_from_stage_index{1}, sample_date_as_string) ;
    first_line_fix_tile_channel_0_file_absolute_path = fullfile(line_fix_folder_path, first_raw_tile_channel_0_file_relative_path) ;
    nominal_line_fix_tif_file_size = get_file_size(first_line_fix_tile_channel_0_file_absolute_path) ;
    fprintf('Nominal line-fix tiff file size is: %d\n', nominal_line_fix_tif_file_size) ;
    
    stage_count = length(stage_name_from_index) ;
    for stage_index = 1 : stage_count ,
        stage_name = stage_name_from_index{stage_index} ;
        pipeline_output_folder_path_template = pipeline_output_folder_path_template_from_stage_index{stage_index} ;
        stage_pipeline_output_tile_folder_path = sprintf(pipeline_output_folder_path_template, sample_date_as_string) ;
        problematic_stage_output_file_relative_paths = cell(1,0) ;
        problematic_stage_output_file_messages = cell(1,0) ;
        fprintf('\n')
        fprintf('Checking stage %s...\n', stage_name) ;
        if do_show_progress , 
            progress_bar = progress_bar_object(subset_tile_count) ;
        end
        for subsset_tile_index = 1 : subset_tile_count ,
            tile_index = tile_index_from_subset_tile_index(subsset_tile_index) ;
            raw_tile_folder_relative_path = relative_path_from_tile_index{tile_index} ;
            [~,leaf_folder_name] = fileparts2(raw_tile_folder_relative_path) ;
            if isequal(stage_name, 'classifier') ,
                putative_stage_output_tile_file_name_template = sprintf('%s-prob.%%d.h5', leaf_folder_name) ;
                are_channels = true ;
            elseif isequal(stage_name, 'descriptor') ,
                putative_stage_output_tile_file_name_template = sprintf('%s-desc.%%d.txt', leaf_folder_name) ;
                are_channels = true ;
            elseif isequal(stage_name, 'point-match') ,
                %putative_stage_output_tile_file_name_template = 'match-Z.mat' ;
                putative_stage_output_tile_file_name_template = 'channel-%d-match-Z.mat' ;
                are_channels = true ;
            else
                putative_stage_output_tile_file_name_template = sprintf('%s-ngc.%%d.tif', leaf_folder_name) ;
                are_channels = true ;
            end
            if are_channels ,
                for channel_index = 0:1 ,
                    putative_stage_output_tile_file_name = sprintf(putative_stage_output_tile_file_name_template, channel_index) ;
                    putative_stage_output_tile_relative_path = fullfile(raw_tile_folder_relative_path, ...
                                                                        putative_stage_output_tile_file_name) ;                                                                
                    putative_stage_output_tile_absolute_path = fullfile(stage_pipeline_output_tile_folder_path, ...
                                                                        putative_stage_output_tile_relative_path) ;
                    if exist(putative_stage_output_tile_absolute_path, 'file') ,
                        if isequal(stage_name, 'raw') ,
                            [problematic_stage_output_file_relative_paths, problematic_stage_output_file_messages] = ...
                                check_raw_tile(stage_pipeline_output_tile_folder_path, ...
                                               putative_stage_output_tile_relative_path, ...
                                               nominal_raw_tif_file_size, ...
                                               nominal_tile_shape_yxz, ...
                                               problematic_stage_output_file_relative_paths, ...
                                               problematic_stage_output_file_messages) ;
                        elseif isequal(stage_name, 'line-fix') ,
                            [problematic_stage_output_file_relative_paths, problematic_stage_output_file_messages] = ...
                                check_raw_tile(stage_pipeline_output_tile_folder_path, ...
                                               putative_stage_output_tile_relative_path, ...
                                               nominal_line_fix_tif_file_size, ...
                                               nominal_tile_shape_yxz, ...
                                               problematic_stage_output_file_relative_paths, ...
                                               problematic_stage_output_file_messages) ;
                        elseif isequal(stage_name, 'classifier') ,
                            [problematic_stage_output_file_relative_paths, problematic_stage_output_file_messages] = ...
                                check_classifier_tile(stage_pipeline_output_tile_folder_path, ...
                                                      putative_stage_output_tile_relative_path, ...
                                                      nominal_raw_tif_file_size, ...
                                                      nominal_tile_shape_yxz, ...
                                                      problematic_stage_output_file_relative_paths, ...
                                                      problematic_stage_output_file_messages) ;
                        end
                    else
                        if strcmp(stage_name, 'point-match') ,
                            % It might still be ok, if there's no z+1 tile for this tile
                            tile_ijk1 = ijk1_from_tile_index(tile_index,:) ;
                            neighbor_tile_ijk1 = tile_ijk1 + [0 0 1] ;
                            if all( 1<=neighbor_tile_ijk1 & neighbor_tile_ijk1<=raw_tile_map_shape ) ,
                                % the neighbor tile is in-bounds
                                neighbor_tile_index = tile_index_from_tile_ijk1(neighbor_tile_ijk1(1), neighbor_tile_ijk1(2), neighbor_tile_ijk1(3)) ;
                                if isfinite(neighbor_tile_index) ,
                                    % the neighbor tile is in bounds, and exists, do its definitely bad that it's
                                    % missing
                                    is_ok = false ;
                                else
                                    % the neighbor tile is in bounds, but doesn't exist in the raw tiles, do ok
                                    % that's the point-match tile is missing for the current tile.
                                    is_ok = true ;
                                end
                            else
                                % the neighbor tile is out-of-bounds, so it's ok that the tile folder is missing
                                % for the current tile
                                is_ok = true ;
                            end
                        else                            
                            is_ok = false ;
                        end                            
                        if is_ok ,
                            % do nothing
                        else
                            problematic_stage_output_file_relative_paths = ...
                                horzcat(problematic_stage_output_file_relative_paths, ...
                                putative_stage_output_tile_relative_path) ; %#ok<AGROW>
                            problematic_stage_output_file_messages = ...
                                horzcat(problematic_stage_output_file_messages, ...
                                sprintf('%s is missing', putative_stage_output_tile_relative_path)) ; %#ok<AGROW>
                        end
                    end
                end
            else   
                % If no channels for this stage, the name is just the
                % template
                putative_stage_output_tile_file_name = putative_stage_output_tile_file_name_template ;
                putative_stage_output_tile_relative_path = fullfile(raw_tile_folder_relative_path, ...
                                                                    putative_stage_output_tile_file_name) ;                                                                
                putative_stage_output_tile_absolute_path = fullfile(stage_pipeline_output_tile_folder_path, ...
                                                                    putative_stage_output_tile_relative_path) ;
                if ~exist(putative_stage_output_tile_absolute_path, 'file') ,
                    problematic_stage_output_file_relative_paths = ...
                        horzcat(problematic_stage_output_file_relative_paths, ...
                                putative_stage_output_tile_relative_path) ; %#ok<AGROW>
                    problematic_stage_output_file_messages = ...
                        horzcat(problematic_stage_output_file_messages, ...
                                sprintf('%s is missing', putative_stage_output_tile_relative_path)) ; %#ok<AGROW>
                end
            end 
            
            % Update the progress bar
            if do_show_progress ,
                progress_bar.update() ;
            end
        end

        problematic_file_count = length(problematic_stage_output_file_relative_paths) ;
        fprintf('\n') ;
        fprintf('Problematic %s file count: %d\n', stage_name, problematic_file_count) ;
        problematic_files_to_show_count = min(problematic_file_count,inf) ;
        for index = 1 : problematic_files_to_show_count ,
            problematic_stage_output_file_relative_path = problematic_stage_output_file_relative_paths{index} ;
            problematic_stage_output_file_message = problematic_stage_output_file_messages{index} ;
            % if stage_name == 'raw':
            %     problematic_stage_output_tile_absolute_path = os.path.join(raw_tile_folder_path,
            %                                                                problematic_stage_output_tile_relative_path)
            %     shape = get_tiff_shape(problematic_stage_output_tile_absolute_path)
            %     print('    problematic: %s, shape (zyx) is %s' % (problematic_stage_output_tile_relative_path, shape) )
            % else:
            fprintf('    problematic: %s: %s\n', problematic_stage_output_file_relative_path, problematic_stage_output_file_message) ;
        end
        if problematic_files_to_show_count < problematic_file_count ,
            problematic_files_now_shown_count = problematic_file_count - problematic_files_to_show_count ;
            fprintf('    problematic: (%d more files)\n', problematic_files_now_shown_count) ;
        end
    end
end


