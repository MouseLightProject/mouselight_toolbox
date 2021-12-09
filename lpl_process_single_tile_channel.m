function lpl_process_single_tile_channel(raw_tile_file_name, tile_relative_path, input_root_path, p_map_root_path, landmarks_root_path, ...
                                         do_force_computation, do_run_in_debug_mode)                                    
    % Deal with args
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end

    % Compute the p-map file path
    input_file_path = fullfile(input_root_path, tile_relative_path, raw_tile_file_name) ;
    [~,day_tile_index_as_string] = fileparts2(tile_relative_path) ;
    channel_index0_as_string = channel_index0_as_string_from_tile_file_name(raw_tile_file_name) ;
    p_map_file_name = sprintf('%s-prob.%s.h5', day_tile_index_as_string, channel_index0_as_string) ;
    p_map_tile_folder_path = fullfile(p_map_root_path, tile_relative_path) ;
    p_map_file_path = fullfile(p_map_tile_folder_path, p_map_file_name) ;
    
    % Shell out to run Ilastik
    if do_force_computation || ~exist(p_map_file_path, 'file') ,   
        ensure_folder_exists(p_map_tile_folder_path) ;
        run_ilastik_on_stack(p_map_file_path, input_file_path) ;
    end

    % Generate the landmarks from the p-map
    landmark_file_name = sprintf('%s-desc.%s.txt', day_tile_index_as_string, channel_index0_as_string) ;
    landmark_folder_path = fullfile(landmarks_root_path, tile_relative_path) ;
    landmark_file_path = fullfile(landmark_folder_path, landmark_file_name) ;

    % Make sure the output folder exists
    ensure_folder_exists(landmark_folder_path) ;
    
    % Run the core code
    siz = '[11 11 11]' ;
    sig1 = '[3.405500 3.405500 3.405500]' ;
    sig2 = '[4.049845 4.049845 4.049845]' ;
    ROI = '[5 1019 5 1531 5 250]' ;
    rt = '4' ;    
    exitcode = dogDescriptor(p_map_file_path, landmark_file_path, siz, sig1, sig2, ROI, rt) ;
    if exitcode ~= 0 ,
        error('dogDescriptor() returned a nonzero exit code (%s) when trying to produce output file %s', exitcode, landmark_file_path) ;
    end
end
