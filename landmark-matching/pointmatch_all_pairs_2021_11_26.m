do_force_computation = false ;
script_folder_path = fileparts(mfilename('fullpath')) ;
memo_folder_path = fullfile(script_folder_path, 'memos') ;

% Build an index of the paths to raw tiles
sample_date = '2020-11-26' ;
raw_tiles_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
descriptors_path = fullfile('/nrs/mouselight/pipeline_output', sample_date, 'stage_3_descriptor_output') ;
%z_point_match_path = fullfile('/nrs/mouselight/pipeline_output', sample_date, 'stage_4_point_match_output') ;
z_point_match_path = fullfile(script_folder_path, sample_date, 'stage_4_point_match_output') ;

% Build the tile index
raw_tile_index = compute_or_read_from_memo(memo_folder_path, ...
                                           sprintf('raw-tile-index-%s', sample_date), ...
                                           @()(build_raw_tile_index(raw_tiles_path)), ...
                                           do_force_computation) ;
tile_index_from_ijk1 = raw_tile_index.tile_index_from_ijk1 ;
ijk1_from_tile_index = raw_tile_index.ijk1_from_tile_index ;
xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;
raw_tile_map_shape = size(tile_index_from_ijk1)
tile_count = length(relative_path_from_tile_index) 

% Determine which pairs will be run
central_tile_relative_path_from_pair_index = cell(tile_count,1) ;
other_tile_relative_path_from_pair_index = cell(tile_count,1) ;
central_tile_ijk1_from_pair_index = nan(tile_count, 3) ;
pair_count_so_far = 0 ;
for center_tile_index = 1 : tile_count ,
    center_ijk1 = ijk1_from_tile_index(center_tile_index, :) ;
    other_ijk1 = center_ijk1 + [0 0 1] ;
    if all(other_ijk1 <= raw_tile_map_shape) ,
        other_tile_index = tile_index_from_ijk1(other_ijk1(1), other_ijk1(2), other_ijk1(3)) ;
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

% Run z point match on all tiles
fprintf('Running z-point-matching on %d valid tile pairs...\n', pair_count) ;
pbo = progress_bar_object(pair_count) ;
parfor pair_index = 1 : pair_count ,
    center_tile_relative_path = central_tile_relative_path_from_pair_index{pair_index} ;
    other_tile_relative_path = other_tile_relative_path_from_pair_index{pair_index} ;
    central_tile_ijk1 = central_tile_ijk1_from_pair_index(pair_index, :) ;
    run_pointmatch_on_single_pair(raw_tiles_path, ...
                                  descriptors_path, ...
                                  z_point_match_path, ...
                                  center_tile_relative_path, ...
                                  central_tile_ijk1, ...
                                  other_tile_relative_path)
    pbo.update() ;
end
%pbo = progress_bar_object(0) ;

% Declare victory
fprintf('Done running z-point-match for all tiles.\n') ;
