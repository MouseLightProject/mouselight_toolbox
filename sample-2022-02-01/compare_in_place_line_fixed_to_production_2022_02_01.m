% Set parameters
do_force_computation = false ;

% Build an index of the paths to raw tiles
sample_date = '2022-02-01' ;
script_folder_path = fileparts(mfilename('fullpath')) ;
fluorescence_root_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date) ;
line_fix_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_date) ;


% Set up the par pool
use_this_fraction_of_cores(1) ;

% Build the tile index
raw_tile_index = compute_or_read_from_memo(sample_memo_folder_path, ...
                                           'raw-tile-index', ...
                                           @()(build_raw_tile_index(fluorescence_root_path)), ...
                                           do_force_computation) ;
tile_index_from_tile_ijk1 = raw_tile_index.tile_index_from_tile_ijk1 ;
ijk1_from_tile_index = raw_tile_index.ijk1_from_tile_index ;
%xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;
%raw_tile_map_shape = size(tile_index_from_tile_ijk1)
tile_count = length(relative_path_from_tile_index)  %#ok<NOPTS>


do_shifts_match_from_tile_index = false(tile_count,1) ;
pbo = progress_bar_object(tile_count) ;
parfor tile_index = 1 : tile_count ,
    tile_relative_path = relative_path_from_tile_index{tile_index} ;
    xlineshift_file_path = fullfile(line_fix_root_path, tile_relative_path, 'Xlineshift.txt') ;
    production_shift = read_xlineshift_file(xlineshift_file_path) ;
    fluorescence_tile_path = fullfile(fluorescence_root_path, tile_relative_path) ;    
    tile_metadata = read_tile_metadata(fluorescence_tile_path) ;
    in_place_shift = tile_metadata.shift ;
    do_shifts_match_from_tile_index(tile_index) = (production_shift==in_place_shift) ;
    pbo.update() ;  %#ok<PFBNS>
end

do_all_shifts_match = all(do_shifts_match_from_tile_index)  %#ok<NOPTS>
