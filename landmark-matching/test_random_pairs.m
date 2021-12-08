do_force_computation = false ;
script_folder_path = fileparts(mfilename('fullpath')) ;
memo_folder_path = fullfile(script_folder_path, 'memos') ;

% Build an index of the paths to raw tiles
sample_date = '2020-09-15' ;
raw_tile_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
raw_tile_index = compute_or_read_from_memo(memo_folder_path, ...
                                           'raw_tile_index', ...
                                           @()(build_raw_tile_index(raw_tile_path)), ...
                                           do_force_computation) ;
raw_tile_map = raw_tile_index.raw_tile_map ;
xyz_from_tile_index = raw_tile_index.xyz_from_tile_index ;
relative_path_from_tile_index = raw_tile_index.relative_path_from_tile_index ;

raw_tile_map_shape = size(raw_tile_map)
tile_count = length(relative_path_from_tile_index) 
random_pair_count = 100 ;
random_pair_done_count = 0 ;
random_pair_passed_count = 0 ;
rng(0) ;  % seed the RNG to get a repeatable sequence of random ints
while random_pair_done_count < random_pair_count ,
    center_tile_index = randi(tile_count, 1) ;
    center_xyz = xyz_from_tile_index(center_tile_index, :) ;
    other_xyz = center_xyz + [0 0 1] ;
    if all(other_xyz <= raw_tile_map_shape) ,
        other_tile_relative_path = raw_tile_map{other_xyz(1), other_xyz(2), other_xyz(3)} ;
        if ~isempty(other_tile_relative_path) ,
            center_tile_relative_path = relative_path_from_tile_index{center_tile_index} ;
            try 
                test_pointmatch_on_single_pair_in_live_sample(sample_date, center_tile_relative_path, other_tile_relative_path) ;
                random_pair_passed_count = random_pair_passed_count + 1 ;
            catch me
                fprintf('Test failed for tile_index %d, relative path %s\n', center_tile_index, center_tile_relative_path) ;
                disp(me.getReport())
            end
            random_pair_done_count = random_pair_done_count + 1 ;
        end
    end
end

fprintf('FINAL RESULT: %d of %d pairs passed\n', random_pair_passed_count, random_pair_done_count) ;
