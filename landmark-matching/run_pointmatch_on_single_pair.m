function run_pointmatch_on_single_pair(raw_tiles_path, ...
                                       descriptors_path, ...
                                       z_point_match_path, ...
                                       central_tile_relative_path, ...
                                       central_tile_ijk1, ...
                                       other_tile_relative_path)
    % Set paths to inputs, outputs
    tile1 = fullfile(descriptors_path, central_tile_relative_path) ;
    tile2 = fullfile(descriptors_path, other_tile_relative_path) ;
    acqusitionfolder1 = fullfile(raw_tiles_path, central_tile_relative_path) ;
    acqusitionfolder2 = fullfile(raw_tiles_path, other_tile_relative_path) ;
    output_folder_path = fullfile(z_point_match_path, central_tile_relative_path) ;
    
    % Run the code under test
    pixel_shift = '[0 0 0]' ;
    max_descriptor_count = 10000 ;
    try
        exitcode = pointmatch(tile1, tile2, acqusitionfolder1, acqusitionfolder2, output_folder_path, pixel_shift, central_tile_ijk1, max_descriptor_count) ;
        if exitcode ~= 0 ,
            warning('pointmatch() returned a nonzero exit code (%s) for central tile %s', exitcode, central_tile_relative_path) ;
        end
    catch me
        warning('pointmatch() produced an error for central tile %s:\n', central_tile_relative_path, me.getReport()) ;
    end
end
