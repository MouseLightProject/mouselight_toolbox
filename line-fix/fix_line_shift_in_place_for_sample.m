function relative_path_from_tile_index = fix_line_shift_in_place_for_sample(...
        tile_root_path, sample_memo_folder_path, do_use_bqueue, do_actually_submit, do_run_in_debug_mode)

    % % Build an index of the paths to raw tiles
    % sample_tag = '2021-10-19' ;
    % analysis_tag = 'get-stragglers' ;
    % raw_tiles_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_tag) ;
    % script_folder_path = fileparts(mfilename('fullpath')) ;
    % sample_memo_folder_path = fullfile(script_folder_path, 'memos', sample_tag) ;
    % analysis_memo_folder_path = fullfile(sample_memo_folder_path, analysis_tag) ;
    % %line_fix_path = fullfile(analysis_memo_folder_path, 'stage_1_line_fix_output') ;
    % line_fix_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_tag) ;
    % do_write_ancillary_files = true ;

    % Set up the par pool
    use_this_fraction_of_cores(1) ;

    % Build the tile index
    do_force_computation = false ;
    raw_tile_index = compute_or_read_from_memo(sample_memo_folder_path, ...
                                               'raw-tile-index', ...
                                               @()(build_raw_tile_index(tile_root_path)), ...
                                               do_force_computation) ;
    %tile_index_from_tile_ijk1 = raw_tile_index.tile_index_from_tile_ijk1 ;
    %ijk1_from_tile_index = raw_tile_index.ijk1_from_tile_index ;
    %xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
    relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;
    %raw_tile_map_shape = size(tile_index_from_tile_ijk1)
    tile_count = length(relative_path_from_tile_index) 

    % Read the original sample metadata
    original_sample_metadata = read_original_sample_metadata(tile_root_path) ;


    %
    % Figure out which tiles need to be run
    %

    fprintf('Determining which of the %d tiles need to be run...\n', tile_count) ;
    is_to_be_run_from_tile_index = true(tile_count, 1) ;
%     if do_force_computation ,
%         is_to_be_run_from_tile_index = true(tile_count, 1) ;
%     else
%         is_to_be_run_from_tile_index = true(tile_count,1) ;
%         pbo = progress_bar_object(tile_count) ;
%         for tile_index = 1 : tile_count
%             tile_relative_path = relative_path_from_tile_index{tile_index} ;
%             is_to_be_run = ...
%                 ~exist(fullfile(line_fix_path,tile_relative_path,'Xlineshift.txt'), 'file') ;
%             is_to_be_run_from_tile_index(tile_index) = is_to_be_run ;
%             pbo.update() ;  %#ok<PFBNS>
%         end
%     end
    fprintf('Done determining which of the %d tiles need to be run.\n', tile_count) ;
    tile_index_from_tile_to_be_run_index = find(is_to_be_run_from_tile_index) ;
    relative_path_from_tile_to_be_run_index = relative_path_from_tile_index(is_to_be_run_from_tile_index) ;
    tile_to_be_run_count = length(tile_index_from_tile_to_be_run_index)


    %
    % Run line-fix on all tiles
    %

    % Create the bqueue
    max_running_slot_count = 800 ;
    bsub_option_string = '-P mouselight -J line-fix' ;
    slots_per_job = 2 ;
    stdouterr_file_path = '' ;  % will go to /dev/null

    if do_use_bqueue , 
        fprintf('Queuing line-fixing on %d tiles...\n', tile_to_be_run_count) ;
        bqueue = bqueue_type(do_actually_submit, max_running_slot_count) ;
        pbo = progress_bar_object(tile_to_be_run_count) ;    
        for tile_to_be_run_index = 1 : tile_to_be_run_count ,
            tile_relative_path = relative_path_from_tile_to_be_run_index{tile_to_be_run_index} ;
            %output_folder_path = fullfile(line_fix_path, tile_relative_path) ;
            %ensure_folder_exists(output_folder_path) ;  % so stdout has somewhere to go
            %stdouterr_file_path = fullfile(output_folder_path, 'stdouterr-run-2.txt') ;
            bqueue.enqueue(slots_per_job, stdouterr_file_path, bsub_option_string, ...
                @fix_line_shift_in_place, ...
                tile_root_path, ...
                tile_relative_path, ...
                original_sample_metadata, ...
                do_run_in_debug_mode) ;
            pbo.update() ;
        end
        fprintf('Done queuing line-fixing on %d tiles.\n\n', tile_to_be_run_count) ;

        fprintf('Running queue on %d tiles...\n', length(bqueue.job_ids)) ;
        maximum_wait_time = inf ;
        do_show_progress_bar = true ;
        tic_id = tic() ;
        job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) ;
        toc(tic_id)
        fprintf('Done running queue on %d tiles.\n', length(bqueue.job_ids)) ;
        job_statuses
        successful_job_count = sum(job_statuses==1)
    else
        fprintf('Running in-place line-fixing on %d tiles...\n', tile_to_be_run_count) ;
        pbo = progress_bar_object(tile_to_be_run_count) ;    
        for tile_to_be_run_index = 1 : tile_to_be_run_count ,
            tile_relative_path = relative_path_from_tile_to_be_run_index{tile_to_be_run_index} ;
            fix_line_shift_in_place( ...
                tile_root_path, ...
                tile_relative_path, ...
                original_sample_metadata, ...
                do_run_in_debug_mode) ;
            pbo.update() ;
        end
        fprintf('Done running in-place line-fixing on %d tiles.\n\n', tile_to_be_run_count) ;
        
    end    
    
    % Finally, convert the original sample metadata to the sample metadata,
    % overwriting the existing file if needed.
    % This makes it easy to tell if a sample has been line-shifted.
    post_line_fix_sample_metadata = post_line_fix_sample_metadata_from_original_sample_metadata(original_sample_metadata) ;
    write_post_line_fix_sample_metadata(tile_root_path, post_line_fix_sample_metadata) ;
end
