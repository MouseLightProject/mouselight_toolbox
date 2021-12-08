function test_pointmatch_on_single_pair_in_live_sample(sample_date, central_tile_relative_path, other_tile_relative_path)
    % Set paths to inputs, outputs
    tile1 = fullfile('/nrs/mouselight/pipeline_output', sample_date, 'stage_3_descriptor_output', central_tile_relative_path) ;
    tile2 = fullfile('/nrs/mouselight/pipeline_output', sample_date, 'stage_3_descriptor_output', other_tile_relative_path) ;
    acqusitionfolder1 = fullfile('/groups/mousebrainmicro/mousebrainmicro/data', sample_date, 'Tiling', central_tile_relative_path) ;
    acqusitionfolder2 = fullfile('/groups/mousebrainmicro/mousebrainmicro/data', sample_date, 'Tiling', other_tile_relative_path) ;
    target_folder_path = fullfile('/nrs/mouselight/pipeline_output', sample_date, 'stage_4_point_match_output', central_tile_relative_path) ;
    %output_folder_path = fullfile(this_folder, 'test-data', sample_date, 'stage_4_point_match_output', central_tile_relative_path) ;
    output_folder_path = [] ;
    
    % Run the code under test
    pixel_shift = '[0 0 0]' ;
    ch = '1' ;
    max_descriptor_count = 10000 ;
    [exitcode,paireddescriptor] = pointmatch(tile1, tile2, acqusitionfolder1, acqusitionfolder2, output_folder_path, pixel_shift, ch, max_descriptor_count) ;
    if exitcode ~= 0 ,
        error('pointmatch() returned a nonzero exit code (%s)', exitcode) ;
    end

    % Load the output, and the target
    target_file_path = fullfile(target_folder_path, 'match-Z.mat') ;
    target = load(target_file_path) ;
    
    % Compare output and target
    if ~isequal(paireddescriptor, target.paireddescriptor) ,
        error('Output for sample %s, central tile %s does not match target.  Output has %d matches, target has %d', ...
              sample_date, central_tile_relative_path, ...
              size(paireddescriptor.X,1), size(target.paireddescriptor.X,1)) ;
    end

    % If get here without error, success!
end
