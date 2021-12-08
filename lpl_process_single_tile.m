function lpl_process_single_tile(tile_relative_path, raw_root_path, line_fix_root_path, p_map_root_path, landmark_root_path, ...
                                 do_line_fix, do_force_computation, do_run_in_debug_mode)
    % sample date something like '2021-09-16'
    % tile_relative_path something like '2021-09-17/00/00000'
    
    % Deal with args
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end
    
%     % Generate paths to various things
%     raw_root_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
%     line_fix_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_date) ;
%     p_map_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', sample_date) ;
%     landmarks_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', sample_date) ;
    
    % Find the tiles in the raw imagery folder
    raw_imagery_folder_path = fullfile(raw_root_path, tile_relative_path) ;
    [~,day_tile_index_string] = fileparts2(tile_relative_path) ;  % e.g. '00000'
    raw_imagery_file_name_template = sprintf('%s-ngc.*.tif', day_tile_index_string) ;
    raw_imagery_file_path_template = fullfile(raw_imagery_folder_path, raw_imagery_file_name_template) ;
    raw_imagery_tile_file_names = simple_dir(raw_imagery_file_path_template) ;
    tile_file_count = length(raw_imagery_tile_file_names) ;
    
    % Fix the line-shift
    if do_line_fix, 
        fix_line_shift(raw_root_path, tile_relative_path, line_fix_root_path, do_force_computation, do_run_in_debug_mode) ;
    end
    
    % Process each tile in turn
    if do_line_fix , 
        p_map_input_root_path = line_fix_root_path ;
    else
        p_map_input_root_path = raw_root_path ;
    end        
    for tile_file_index = 1 : tile_file_count ,
        raw_imagery_tile_file_name = raw_imagery_tile_file_names{tile_file_index} ;                
        lpl_process_single_tile_channel(...
            raw_imagery_tile_file_name, tile_relative_path, p_map_input_root_path, p_map_root_path, landmark_root_path) ;
    end
end
