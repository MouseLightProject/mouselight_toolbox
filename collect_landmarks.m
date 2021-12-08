function ijk0_from_landmark_index_from_tile_index = ...
        collect_landmarks(landmark_folder_path, relative_path_from_tile_index, background_channel_index, tile_shape_ijk)
    
    tile_count = length(relative_path_from_tile_index) ;
    ijk0_from_landmark_index_from_tile_index = cell(tile_count, 1) ;
    for tile_index = 1 : tile_count ,
        tile_relative_path = relative_path_from_tile_index{tile_index} ;
        [~, leaf_folder_name] = fileparts2(tile_relative_path) ;
        landmark_file_name = sprintf('%s-desc.%d.txt', leaf_folder_name, background_channel_index) ;
        landmark_file_path = fullfile(landmark_folder_path, tile_relative_path, landmark_file_name) ;
        if exist(landmark_file_path, 'file') ,
            ijk0_from_landmark_index = load_landmark_file(landmark_file_path, tile_shape_ijk) ;
        else
            fprintf('Missing (?) landmark file for tile %s\n', tile_relative_path) ;
            ijk0_from_landmark_index = zeros(0,3) ;
        end
        ijk0_from_landmark_index_from_tile_index{tile_index} = ijk0_from_landmark_index ;
    end
end
