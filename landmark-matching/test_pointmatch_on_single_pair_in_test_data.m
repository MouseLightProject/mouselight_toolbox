function test_pointmatch_on_single_pair_in_test_data(sample_date, central_tile_relative_path, other_tile_relative_path)
    % Set paths to inputs, outputs
    this_folder = fileparts(mfilename('fullpath')) ;
    tile1 = fullfile(this_folder, 'test-data', sample_date, 'stage_3_descriptor_output', central_tile_relative_path) ;
    tile2 = fullfile(this_folder, 'test-data', sample_date, 'stage_3_descriptor_output', other_tile_relative_path) ;
    acqusitionfolder1 = fullfile(this_folder, 'test-data', sample_date, 'Tiling', central_tile_relative_path) ;
    acqusitionfolder2 = fullfile(this_folder, 'test-data', sample_date, 'Tiling', other_tile_relative_path) ;
    output_folder_path = fullfile(this_folder, 'test-data', sample_date, 'stage_4_point_match_output', central_tile_relative_path) ;
    target_folder_path = fullfile(this_folder, 'test-data', sample_date, 'stage_4_point_match_output_target', central_tile_relative_path) ;

    % We try to delete all files in output_folder_path, so first make sure it's not
    % empty
    if isempty(output_folder_path) ,
        error('No output folder set') ;
    end
    
    % Delete any pre-existing output files
    return_code = system(sprintf('rm -rf %s/*', output_folder_path)) ;
    if return_code ~= 0 ,
        error('Unable to delete contents of %s for test', output_folder_path) ;
    end

    % Run the code under test
    pixel_shift = '[0 0 0]' ;
    ch = [] ;  % this is ignored
    max_descriptor_count = 10000 ;
    exitcode = pointmatch(tile1, tile2, acqusitionfolder1, acqusitionfolder2, output_folder_path, pixel_shift, ch, max_descriptor_count) ;
    if exitcode ~= 0 ,
        error('pointmatch() returned a nonzero exit code (%s) when trying to produce output in folder %s', exitcode, output_folder_path) ;
    end

    % Load the output, and the target
    output_file_path = fullfile(output_folder_path, 'channel-1-match-Z.mat') ;
    target_file_path = fullfile(target_folder_path, 'match-Z.mat') ;
    output = load(output_file_path) ;
    target = load(target_file_path) ;

    % Give an overview of the results
    fprintf('output.paireddescriptor:\n') ;
    disp(output.paireddescriptor) ;
    fprintf('target.paireddescriptor:\n') ;
    disp(target.paireddescriptor) ;    
    
    % Compare output and target
    if ~isequal(output, target) ,
        error('Output for sample %s, central tile %s does not match target', sample_date, central_tile_relative_path) ;
    end

    % Make sure the other output file exists and is readable
    output_file_path = fullfile(output_folder_path, 'channel-0-match-Z.mat') ;
    output = load(output_file_path) ;    
    fprintf('output.paireddescriptor (channel 0):\n') ;
    disp(output.paireddescriptor) ;
    
    % If get here without error, success!
end
