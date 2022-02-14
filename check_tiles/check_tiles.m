function check_tiles(sample_date_as_string, do_show_progress)
    if ~exist('do_show_progress', 'var') || isempty(do_show_progress) ,
        do_show_progress = false ;
    end
    
    raw_tile_folder_path_template = '/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling' ;
    raw_tile_folder_path = sprintf(raw_tile_folder_path_template, sample_date_as_string) ;
    % Sometimes they use a "Tiling" folder, sometimes not...
    if ~exist(raw_tile_folder_path, 'file') ,
        raw_tile_folder_path_template = '/groups/mousebrainmicro/mousebrainmicro/data/acquisition/%s' ;
        raw_tile_folder_path = sprintf(raw_tile_folder_path_template, sample_date_as_string) ;
    end
    pipeline_output_folder_path_template_from_stage_index = {raw_tile_folder_path_template, ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', ...
                                                    '/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output'} ;
    stage_name_from_index = {'raw', 'line-fix', 'classifier', 'descriptor', 'point-match'} ;
    
    % Get a list of all the raw tiles for channel 0.
    % Each tile is represented by its relative path within raw_tile_folder_path
    fprintf('Scanning filesystem for raw tile folders...\n') ;
    raw_tile_folder_relative_paths = collect_raw_tile_folder_relative_paths(raw_tile_folder_path) ;
    fprintf('Done scanning filesystem for raw tile folders.\n') ;
    
    % Report the number of tiles
    raw_tile_count = length(raw_tile_folder_relative_paths) ;
    fprintf('Raw tile folder count: %d\n', raw_tile_count) ;
    if raw_tile_count==0 ,
        error('There are no raw tiles!') ;
    end
    
    % Get the tile shape
    first_raw_tile_folder_relative_path = raw_tile_folder_relative_paths{1} ;
    [~,first_raw_tile_folder_leaf_name] = fileparts2(first_raw_tile_folder_relative_path) ;
    first_raw_tile_channel_0_file_relative_path = fullfile(first_raw_tile_folder_relative_path, sprintf('%s-ngc.0.tif', first_raw_tile_folder_leaf_name)) ;
    first_raw_tile_channel_0_file_absolute_path = fullfile(raw_tile_folder_path, first_raw_tile_channel_0_file_relative_path) ;
    stack = read_16bit_grayscale_tif(first_raw_tile_channel_0_file_absolute_path) ;
    nominal_tile_shape_yxz = size(stack) ;
    nominal_raw_tif_file_size = get_file_size(first_raw_tile_channel_0_file_absolute_path) ;
    fprintf('Nominal tile shape (yxz) is: [%d %d %d]\n', nominal_tile_shape_yxz) ;
    fprintf('Nominal uncompressed tiff file size is: %d\n', nominal_raw_tif_file_size) ;

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
            progress_bar = progress_bar_object(raw_tile_count) ;
        end
        for raw_tile_index = 1 : raw_tile_count ,
            raw_tile_folder_relative_path = raw_tile_folder_relative_paths{raw_tile_index} ;
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
                        problematic_stage_output_file_relative_paths = ...
                            horzcat(problematic_stage_output_file_relative_paths, ...
                                    putative_stage_output_tile_relative_path) ; %#ok<AGROW>
                        problematic_stage_output_file_messages = ...
                            horzcat(problematic_stage_output_file_messages, ...
                                    sprintf('%s is missing', putative_stage_output_tile_relative_path)) ; %#ok<AGROW>
                    end
                end
            else   
                % If no channels for this stage, the name is jus the
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
                progress_bar.update(raw_tile_index)
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


