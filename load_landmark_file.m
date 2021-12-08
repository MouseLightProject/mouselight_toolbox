function [ijk0_from_landmark_index, foreground_p_value_from_landmark_index, imagery_value_from_landmark_index] =...
        load_landmark_file(landmark_file_name, tile_shape_ijk)
    landmark_data = load_tabular_data(landmark_file_name) ;
    if isempty(landmark_data) ,
        ijk0_from_landmark_index = zeros(0,3) ;
    else
        flipped_ijk0_from_landmark_index = landmark_data(:,1:3) ;
        % the landmark-detection code is run on the the raw (flipped in x and y) tiles,
        % so need to un-flip the landmarks
        ijk0_from_landmark_index = ...
            [ (tile_shape_ijk(1)-1) - flipped_ijk0_from_landmark_index(:,1) ...
              (tile_shape_ijk(2)-1) - flipped_ijk0_from_landmark_index(:,2) ...
              flipped_ijk0_from_landmark_index(:,3) ] ;
    end
    foreground_p_value_from_landmark_index = landmark_data(:,4) ;
    imagery_value_from_landmark_index = landmark_data(:,5) ;
end
