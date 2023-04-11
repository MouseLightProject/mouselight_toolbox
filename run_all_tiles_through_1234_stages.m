% Set up the par pool
use_this_fraction_of_cores(1) ;

% Set params for early jobs
do_try = [] ;
max_running_slot_count = inf ;
bsub_option_string = '-P mouselight -J mouselight-pipeline-123' ;
slots_per_job = 4 ;
stdouterr_file_path = '' ;  % will go to /dev/null


% Build the tile index
raw_tile_index = compute_or_read_from_memo(sample_memo_folder_path, ...
                                           'raw-tile-index', ...
                                           @()(build_raw_tile_index(raw_root_path)), ...
                                           do_force_computation) ;
tile_index_from_tile_ijk1 = raw_tile_index.tile_index_from_tile_ijk1 ;
ijk1_from_tile_index = raw_tile_index.ijk1_from_tile_index ;
%xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;
%raw_tile_map_shape = size(tile_index_from_tile_ijk1)
tile_count = length(relative_path_from_tile_index)  %#ok<NOPTS>



%
% Figure out which tiles need to be run
%

%is_to_be_run_from_tile_index = false(tile_count, 1) ;
%is_to_be_run_from_tile_index(1:20) = true ;
fprintf('Determining which of the %d tiles need to be LPLed...\n', tile_count) ;
if do_force_computation ,
    is_to_be_run_from_tile_index = true(tile_count, 1) ;
else
    is_to_be_run_from_tile_index = true(tile_count,1) ;
    pbo = progress_bar_object(tile_count) ;
    parfor tile_index = 1 : tile_count
        tile_relative_path = relative_path_from_tile_index{tile_index} ;
        channel_0_tile_file_name = landmark_file_name_from_tile_relative_path(tile_relative_path, 0) ;
        channel_0_tile_file_path = fullfile(landmark_root_path, tile_relative_path, channel_0_tile_file_name) ;
        channel_1_tile_file_name = landmark_file_name_from_tile_relative_path(tile_relative_path, 1) ;
        channel_1_tile_file_path = fullfile(landmark_root_path, tile_relative_path, channel_1_tile_file_name) ;        
        is_to_be_run = ...
            ~(exist(channel_0_tile_file_path, 'file') && exist(channel_1_tile_file_path, 'file')) ;
        is_to_be_run_from_tile_index(tile_index) = is_to_be_run ;
        pbo.update() ;  %#ok<PFBNS>
    end
    %pbo = progress_bar_object(0) ;
end
fprintf('Done determining which of the %d tiles need to be LPLed.\n', tile_count) ;
tile_index_from_tile_to_be_run_index = find(is_to_be_run_from_tile_index) ;
relative_path_from_tile_to_be_run_index = relative_path_from_tile_index(is_to_be_run_from_tile_index) ;
tile_to_be_run_count = length(tile_index_from_tile_to_be_run_index)  %#ok<NOPTS>
 

%
% Run stages 123 on all tiles
%

% Create the bqueue
if do_use_bsub ,
    fprintf('Queueing LPL on %d tiles...\n', tile_to_be_run_count) ;
    bqueue = bqueue_type(do_actually_submit, do_try, max_running_slot_count) ;
    pbo = progress_bar_object(tile_to_be_run_count) ;
    for tile_to_be_run_index = 1 : tile_to_be_run_count ,
        tile_relative_path = relative_path_from_tile_to_be_run_index{tile_to_be_run_index} ;
        %output_folder_path = fullfile(line_fix_path, tile_relative_path) ;
        %ensure_folder_exists(output_folder_path) ;  % so stdout has somewhere to go
        %stdouterr_file_path = fullfile(output_folder_path, 'stdouterr-run-2.txt') ;
        bqueue.enqueue(slots_per_job, stdouterr_file_path, bsub_option_string, ...
            @lpl_process_single_tile, ...
            tile_relative_path, ...
            raw_root_path, ...
            line_fix_root_path, ...
            p_map_root_path, ...
            landmark_root_path, ...
            do_line_fix, ...
            ilastik_project_file_name, ...
            do_force_computation) ;
        pbo.update() ;
    end
    %pbo = progress_bar_object(0) ;
    fprintf('Done queueing LPL on %d tiles.\n\n', tile_to_be_run_count) ;
    
    fprintf('LPLing queue on %d tiles...\n', length(bqueue.job_ids)) ;
    maximum_wait_time = inf ;
    do_show_progress_bar = true ;
    tic_id = tic() ;
    job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) ;
    toc(tic_id)
    fprintf('Done LPLing queue on %d tiles.\n', length(bqueue.job_ids)) ;
    successful_job_count = sum(job_statuses==1)  %#ok<NOPTS>
else
    % Useful for debugging
    pbo = progress_bar_object(tile_to_be_run_count) ;
    for tile_to_be_run_index = 1 : tile_to_be_run_count ,
        tile_relative_path = relative_path_from_tile_to_be_run_index{tile_to_be_run_index} ;
        %output_folder_path = fullfile(line_fix_path, tile_relative_path) ;
        %ensure_folder_exists(output_folder_path) ;  % so stdout has somewhere to go
        %stdouterr_file_path = fullfile(output_folder_path, 'stdouterr-run-2.txt') ;
        lpl_process_single_tile( ...
            tile_relative_path, ...
            raw_root_path, ...
            line_fix_root_path, ...
            p_map_root_path, ...
            landmark_root_path, ...
            do_line_fix, ...
            ilastik_project_file_name, ...
            do_force_computation) ;
        pbo.update() ;
    end
    %pbo = progress_bar_object(0) ;    
end


% 
% Run stage 4 (landmark matching)
% We bqueue up a single job that will use 48 cores
%

% New params for bjobs
matching_do_try = [] ;
matching_max_running_slot_count = inf ;
matching_bsub_option_string = '-P mouselight -J mouselight-landmark-matching' ;
matching_slots_per_job = 48 ;
matching_stdouterr_file_path = fullfile(script_folder_path, 'mouselight-landmark-matching.out.txt') ;

% Create the bqueue
if do_use_bsub ,
    fprintf('Running landmark-matching (as single bsub job)...\n') ;
    bqueue = bqueue_type(do_actually_submit, matching_do_try, matching_max_running_slot_count) ;
        bqueue.enqueue(matching_slots_per_job, matching_stdouterr_file_path, matching_bsub_option_string, ...
            @landmark_match_all_tiles_in_z, ...
            raw_root_path, ...
            sample_memo_folder_path, ...
            landmark_root_path, ...
            z_point_match_root_path, ...
            do_force_computation, ...
            do_run_in_debug_mode) ;
    maximum_wait_time = inf ;
    do_show_progress_bar = false ;
    tic_id = tic() ;
    job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) ;
    toc(tic_id)
    if all(job_statuses==1) ,
        fprintf('Done running landmark-matching.\n\n') ;
    else
        fprintf('Done running landmark-matching, but the job returned a non-zero error code.\n\n') ;
    end
else
    % Useful for debugging
    landmark_match_all_tiles_in_z( ...
            raw_root_path, ...
            sample_memo_folder_path, ...
            landmark_root_path, ...
            z_point_match_root_path, ...
            do_force_computation, ...
            do_run_in_debug_mode) ;
end
