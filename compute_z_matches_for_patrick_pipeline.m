function compute_z_matches_for_patrick_pipeline(landmarks_root_path, z_matches_root_path, tile_relative_path, ...
                                                fluorescence_root_path, other_tile_relative_path)                                        
                                          
    % Print inputs, useful for debugging:
    name_from_argument_index = who() ;
    fprintf('Inputs to %s:\n', mfilename()) ;
    for argument_index = 1 : length(name_from_argument_index) ,
        name = name_from_argument_index{argument_index} ;
        value = eval(name) ;
        fprintf('%s: %s\n', name, value) ;
    end
    fprintf('\n') ;                      
    
    % Synthesize all the tile folder paths
    central_tile_landmark_folder_path = fullfile(landmarks_root_path, tile_relative_path) ;
    other_tile_landmark_folder_path = fullfile(landmarks_root_path, other_tile_relative_path) ;
    central_tile_fluorescence_folder_path = fullfile(fluorescence_root_path, tile_relative_path) ;
    other_tile_fluorescence_folder_path = fullfile(fluorescence_root_path, other_tile_relative_path) ;
    output_folder_name = fullfile(z_matches_root_path, tile_relative_path) ;
    
    % Run for all channels
    pointmatch(central_tile_landmark_folder_path, ...
               other_tile_landmark_folder_path, ...
               central_tile_fluorescence_folder_path, ...
               other_tile_fluorescence_folder_path, ...
               output_folder_name) ;
end
