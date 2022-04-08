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
    tile_count = length(relative_path_from_tile_index) ;
    fprintf('Sample tile count: %d\n', tile_count) ;

    % Read the original sample metadata
    original_sample_metadata = read_original_sample_metadata(tile_root_path) ;


    %
    % Figure out which tiles need to be run
    %

    fprintf('Determining which of the %d tiles need to be run...\n', tile_count) ;
    %is_to_be_run_from_tile_index = true(tile_count, 1) ;
    if do_force_computation ,
        does_need_to_be_run_from_tile_index = true(tile_count, 1) ;
    else
        does_need_to_be_run_from_tile_index = true(tile_count,1) ;
        pbo = progress_bar_object(tile_count) ;
        parfor tile_index = 1 : tile_count
            tile_relative_path = relative_path_from_tile_index{tile_index} ;
            is_to_be_run = ...
                ~exist(fullfile(tile_root_path,tile_relative_path,'tile-metadata.txt'), 'file') ;
            does_need_to_be_run_from_tile_index(tile_index) = is_to_be_run ;
            pbo.update() ;  %#ok<PFBNS>
        end
    end
    fprintf('Done determining which of the %d tiles need to be run.\n', tile_count) ;
    tile_index_from_tile_needs_to_be_run_index = find(does_need_to_be_run_from_tile_index) ;
    relative_path_from_tile_needs_to_be_run_index = relative_path_from_tile_index(does_need_to_be_run_from_tile_index) ;
    tile_needs_to_be_run_count = length(tile_index_from_tile_needs_to_be_run_index) ;
    fprintf('Number of tiles that need to be run: %d\n', tile_needs_to_be_run_count) ;

    % Figure out how many tile's we're going to run
    if do_run_in_debug_mode && ~isempty(tile_index_from_tile_needs_to_be_run_index),
        % If in debug mode, just run one tile
        fprintf('Only going to run one tile because we''re in debug mode...\n') ;
        tile_index_from_to_be_run_index = tile_index_from_tile_needs_to_be_run_index(1) ;
        relative_path_from_tile_to_be_run_index = relative_path_from_tile_needs_to_be_run_index(1) ;
        fprintf('  Tile index is %d\n', tile_index_from_to_be_run_index) ;
        fprintf('  Tile relative path is %s\n', relative_path_from_tile_to_be_run_index{1}) ;        
    else
        % If not debugging, run all the tiles
        tile_index_from_to_be_run_index = tile_index_from_tile_needs_to_be_run_index ;
        relative_path_from_tile_to_be_run_index = relative_path_from_tile_needs_to_be_run_index ;
    end
    tile_to_be_run_count = length(tile_index_from_to_be_run_index) ;
    fprintf('Number of tiles to be run: %d\n', tile_to_be_run_count) ;
        


    %
    % Run line-fix on all tiles
    %

    % Create the bqueue
    max_running_slot_count = 800 ;
    bsub_option_string = '-P mouselight -J line-fix' ;
    slots_per_job = 2 ;

    if do_use_bqueue , 
        fprintf('Queuing line-fixing on %d tiles...\n', tile_to_be_run_count) ;
        bqueue = bqueue_type(do_actually_submit, max_running_slot_count) ;
        pbo = progress_bar_object(tile_to_be_run_count) ;
        for tile_to_be_run_index = 1 : tile_to_be_run_count ,
            tile_relative_path = relative_path_from_tile_to_be_run_index{tile_to_be_run_index} ;
            if do_run_in_debug_mode ,
                output_folder_path = fullfile(tile_root_path, tile_relative_path) ;
                ensure_folder_exists(output_folder_path) ;  % so stdout has somewhere to go
                stdouterr_file_path = fullfile(output_folder_path, 'fix_line_shift_in_place_stdouterr.txt') ;
                fprintf('Stdouterr file path is %s\n', stdouterr_file_path) ;
            else
                stdouterr_file_path = '' ;  % will go to /dev/null                
            end
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
        %job_statuses
        successful_job_count = sum(job_statuses==1) ;
        fprintf('Successful job count: %d\n', successful_job_count) ;
    else
        fprintf('Running in-place line-fixing on %d tiles...\n', tile_to_be_run_count) ;
        job_statuses = zeros(1, tile_to_be_run_count) ;
        pbo = progress_bar_object(tile_to_be_run_count) ;    
        for tile_to_be_run_index = 1 : tile_to_be_run_count ,
            tile_relative_path = relative_path_from_tile_needs_to_be_run_index{tile_to_be_run_index} ;
            fix_line_shift_in_place( ...
                tile_root_path, ...
                tile_relative_path, ...
                original_sample_metadata, ...
                do_run_in_debug_mode) ;
            job_statuses(tile_to_be_run_index) = +1 ;
            pbo.update() ;
        end
        fprintf('Done running in-place line-fixing on %d tiles.\n\n', tile_to_be_run_count) ;        
    end    
    
    % Finally, convert the original sample metadata to the sample metadata,
    % overwriting the existing file if needed.
    % This makes it easy to tell if a sample has been line-shifted.
    if all(job_statuses==1) 
        if (tile_to_be_run_count==tile_needs_to_be_run_count) ,
            post_line_fix_sample_metadata = post_line_fix_sample_metadata_from_original_sample_metadata(original_sample_metadata) ;
            write_post_line_fix_sample_metadata(tile_root_path, post_line_fix_sample_metadata) ;
        else
            fprintf('Not writing post-line-fix sample metadata file b/c we didn''t run all the tiles that need running.\n') ;
        end
    else
        error('There was a problem with one or more tiles.  Not writing post-line-fix sample metadata file.') ;
    end
end
