function landmark_match_all_tiles_in_z( ...
        raw_root_path, ...
        sample_memo_folder_path, ...
        landmark_root_path, ...
        z_point_match_root_path, ...
        do_force_computation, ...
        do_run_in_debug_mode)

%     % Build an index of the paths to raw tiles
%     sample_date = '2021-09-16' ;
%     script_folder_path = fileparts(mfilename('fullpath')) ;
%     raw_root_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
%     sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date) ;
%     line_fix_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_date) ;
%     p_map_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', sample_date) ;
%     landmark_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', sample_date) ;
%     z_point_match_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output', sample_date) ;



    % Set up the par pool
    use_this_fraction_of_cores(1) ;

    % Build the tile index
    raw_tile_index = compute_or_read_from_memo(sample_memo_folder_path, ...
                                               'raw-tile-index', ...
                                               @()(build_raw_tile_index(raw_root_path)), ...
                                               do_force_computation) ;
    tile_index_from_tile_ijk1 = raw_tile_index.tile_index_from_tile_ijk1 ;
    ijk1_from_tile_index = raw_tile_index.ijk1_from_tile_index ;
    %xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
    relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;
    raw_tile_map_shape = size(tile_index_from_tile_ijk1)
    tile_count = length(relative_path_from_tile_index) 

    % Read the sample metadata
    sample_metadata = read_sample_metadata_robustly(raw_root_path) ;

    % 
    % Run stage 4 (landmark matching)
    %

    % Determine which tiles have a z+1 neighbor
    central_tile_relative_path_from_pair_index = cell(tile_count,1) ;
    other_tile_relative_path_from_pair_index = cell(tile_count,1) ;
    central_tile_ijk1_from_pair_index = nan(tile_count, 3) ;
    pair_count_so_far = 0 ;
    for center_tile_index = 1 : tile_count ,
        center_ijk1 = ijk1_from_tile_index(center_tile_index, :) ;
        other_ijk1 = center_ijk1 + [0 0 1] ;
        if all(other_ijk1 <= raw_tile_map_shape) ,
            other_tile_index = tile_index_from_tile_ijk1(other_ijk1(1), other_ijk1(2), other_ijk1(3)) ;
            if ~isnan(other_tile_index) ,
                % Found a pair, so add the relative paths to the lists
                other_tile_relative_path = relative_path_from_tile_index{other_tile_index} ;
                center_tile_relative_path = relative_path_from_tile_index{center_tile_index} ;
                pair_count_so_far = pair_count_so_far + 1 ;
                pair_index = pair_count_so_far ;
                central_tile_relative_path_from_pair_index{pair_index} = center_tile_relative_path ;
                other_tile_relative_path_from_pair_index{pair_index} = other_tile_relative_path ;
                central_tile_ijk1_from_pair_index(pair_index, :) = center_ijk1 ;
            end
        end
    end
    pair_count = pair_count_so_far 
    central_tile_relative_path_from_pair_index = central_tile_relative_path_from_pair_index(1:pair_count) ;  % trim
    other_tile_relative_path_from_pair_index = other_tile_relative_path_from_pair_index(1:pair_count) ;  % trim

    % Determine which of the tiles need to be run
    fprintf('Determining which of the %d eligible tiles need to be landmark-matched...\n', pair_count) ;
    % is_to_be_matched_from_pair_index = false(pair_count, 1) ;
    % is_to_be_matched_from_pair_index(1:100) = true ;
    if do_force_computation ,
        is_to_be_matched_from_pair_index = true(pair_count, 1) ;
    else
        is_to_be_matched_from_pair_index = true(pair_count,1) ;
        pbo = progress_bar_object(pair_count) ;
        parfor pair_index = 1 : pair_count
            central_tile_relative_path = central_tile_relative_path_from_pair_index{pair_index} ;
            channel_0_tile_file_name = sprintf('channel-%d-match-Z.mat', 0) ;
            channel_0_tile_file_path = fullfile(z_point_match_root_path, central_tile_relative_path, channel_0_tile_file_name) ;
            channel_1_tile_file_name = sprintf('channel-%d-match-Z.mat', 1) ;
            channel_1_tile_file_path = fullfile(z_point_match_root_path, central_tile_relative_path, channel_1_tile_file_name) ;        
            is_to_be_matched = ...
                ~(exist(channel_0_tile_file_path, 'file') && exist(channel_1_tile_file_path, 'file')) ;
            is_to_be_matched_from_pair_index(pair_index) = is_to_be_matched ;
            pbo.update() ; %#ok<PFBNS>
        end
        %pbo = progress_bar_object(0) ;
    end
    fprintf('Done determining which of the %d eligible tiles need to be landmark-matched.\n', pair_count) ;
    pair_index_from_tile_to_be_matched_index = find(is_to_be_matched_from_pair_index) ;
    central_tile_relative_path_from_tile_to_be_matched_index = central_tile_relative_path_from_pair_index(is_to_be_matched_from_pair_index) ;
    other_tile_relative_path_from_tile_to_be_matched_index = other_tile_relative_path_from_pair_index(is_to_be_matched_from_pair_index) ;
    central_tile_ijk1_from_tile_to_be_matched_index = central_tile_ijk1_from_pair_index(is_to_be_matched_from_pair_index, :) ;
    tile_to_be_matched_count = length(pair_index_from_tile_to_be_matched_index)

    % Run z point match on all tiles
    fprintf('Running z-point-matching on %d tile pairs...\n', tile_to_be_matched_count) ;
    pbo = progress_bar_object(tile_to_be_matched_count) ;
    parfor tile_to_be_matched_index = 1 : tile_to_be_matched_count ,
        center_tile_relative_path = central_tile_relative_path_from_tile_to_be_matched_index{tile_to_be_matched_index} ;
        other_tile_relative_path = other_tile_relative_path_from_tile_to_be_matched_index{tile_to_be_matched_index} ;
        central_tile_ijk1 = central_tile_ijk1_from_tile_to_be_matched_index(tile_to_be_matched_index, :) ;
        run_pointmatch_on_single_pair(raw_root_path, ...
                                      landmark_root_path, ...
                                      z_point_match_root_path, ...
                                      center_tile_relative_path, ...
                                      central_tile_ijk1, ...
                                      other_tile_relative_path, ...
                                      sample_metadata, ...
                                      do_run_in_debug_mode)
        pbo.update() ; %#ok<PFBNS>
    end
    %pbo = progress_bar_object(0) ;

    % Declare victory
    fprintf('Done running z-point-match for all tiles.\n') ;
end
