function visualize_z_matching_after_loading_stacks_and_flipping(...
        central_tile_raw_folder_path, ...
        other_tile_raw_folder_path, ...
        flipped_central_tile_landmark_ijks_and_descriptors, ...
        flipped_other_tile_landmark_ijks_and_descriptors, ...
        nominal_other_tile_offset_ijk, ...
        border_central_tile_landmarks_ijk, ...
        border_other_tile_landmarks_ijk, ...
        flipped_matched_central_tile_landmarks_ijk, ...
        flipped_matched_other_tile_landmarks_ijk, ...
        matching_channel_index, ...
        sample_metadata, ...
        central_tile_relative_path, ...
        other_tile_relative_path)
                 
    % scopeloc: Info about all the raw tiles, including file paths and location in the lattice
    % neighbor_tile_index_from_tile_index_from_axis_index: soemthing x 4 double array, first col is tile index, 2nd col is x+1 tile, 3rd col is y+1 col,
    %        4th col is z+1 col
    % descriptors: 1 x tile_count cell array, each element containing a point_count x 5 double array.  1st three cols
    %              are integer xyz voxel coords of fiducial points (not sure if zero- or one-based), 4th col is DoG
    %              filter value at the point, 5th col is the foreground p-map value at the point.
    % tile_index: index of the row in neighbor_tile_index_from_tile_index_from_axis_index we're going to use to get the central and adjacent tile index.
    %        Seems like the central til index is almost always equal to this, but I guess maybe not always?
    % nominal_other_tile_offset_ijk: 1x3, nominal position of other tile
    %    relative to central tile, in voxels.
    % border_central_tile_landmarks_ijk: something x 3, xyz coords of fiducials in central tile that are likely to be near the overlap
    %    region between the two tiles.
    % border_other_tile_landmarks_ijk: something x 3, xyz coords of fiducials in other tile that are likely to be near the overlap
    %    region between the two tiles.
    % matched_central_tile_landmarks_ijk: match_count x 3, xyz coords of fiducials in central tile for which matches have been found
    %     with other tile.
    % matched_other_tile_landmarks_ijk: match_count x 3, xyz coords of fiducials in other tile for which matches have been found
    %     with central tile.  (I assume ordered to match up with points in X_.)
    % matching_channel_index: The channel used for matching.  Images from this
    %                         channel will be shown.  Usually 0 or 1.
    % sample_metadata: A struct representing the sample_metadata.txt file for
    %                  the sample.  Used to determine how to flip the imagery
    %                  when debugging.
    
%     % nominal_other_tile_offset_ijk will typically only have one non-zero
%     % element.  Determine which axis contains the non-zero element.
%     [~, shifted_axis_index] = max(abs(nominal_other_tile_offset_ijk)) ;  
    
%     % Get the tile indices
%     central_tile_index = neighbor_tile_index_from_tile_index_from_axis_index(tile_index,1) ;  % Isn't this the identity?
%     other_tile_index = neighbor_tile_index_from_tile_index_from_axis_index(tile_index, shifted_axis_index+1) ;
    
    % Load the stacks from disk
    central_tile_raw_file_path = file_path_from_tile_path(central_tile_raw_folder_path, matching_channel_index) ; 
    maybe_flipped_central_tile_stack_jik = read_16bit_grayscale_tif(central_tile_raw_file_path) ;
    other_tile_raw_file_path = file_path_from_tile_path(other_tile_raw_folder_path, matching_channel_index) ; 
    maybe_flipped_other_tile_stack_jik = read_16bit_grayscale_tif(other_tile_raw_file_path) ;
    
%     % Get the landmark ijk coords and descriptors for these two tiles
%     flipped_central_tile_landmark_ijks_and_descriptors = descriptors{central_tile_index};    
%     flipped_other_tile_landmark_ijks_and_descriptors = descriptors{other_tile_index};
    
    % Flip the stacks as needed
    central_tile_flip_metadata = get_tile_flip_state(central_tile_raw_file_path, sample_metadata) ;
    other_tile_flip_metadata = get_tile_flip_state(other_tile_raw_file_path, sample_metadata) ;
    central_tile_stack_jik = unflip_stack_as_needed(maybe_flipped_central_tile_stack_jik, central_tile_flip_metadata) ;
    other_tile_stack_jik = unflip_stack_as_needed(maybe_flipped_other_tile_stack_jik, other_tile_flip_metadata) ;
    
    % Get the stack shape, needed by correctTiles() below
    stack_shape_jik = size(central_tile_stack_jik);  % like yxz, but in pixels
    stack_shape_ijk = stack_shape_jik([2 1 3]) ;  % like xyz, but in pixels
    
    % Unflip the central tile landmark coords
    flipped_central_tile_landmarks_ijk = double(flipped_central_tile_landmark_ijks_and_descriptors(:,1:3)) ;  % get just xyz, not the descriptor values
    central_tile_landmarks_ijk = correctTiles(flipped_central_tile_landmarks_ijk, stack_shape_ijk) ;  % flip dimensions
    
    % Unflip the other tile landmark coords
    flipped_other_tile_landmarks_ijk = double(flipped_other_tile_landmark_ijks_and_descriptors(:,1:3)) ; 
    other_tile_landmarks_ijk = correctTiles(flipped_other_tile_landmarks_ijk, stack_shape_ijk) ;
    
    % Unflip the matched landmarks
    matched_central_tile_landmarks_ijk = correctTiles(flipped_matched_central_tile_landmarks_ijk, stack_shape_ijk) ;
    matched_other_tile_landmarks_ijk = correctTiles(flipped_matched_other_tile_landmarks_ijk, stack_shape_ijk) ;

    % Call the core visualization function
    visualize_z_matching(central_tile_stack_jik, other_tile_stack_jik, ...
                         central_tile_landmarks_ijk, other_tile_landmarks_ijk, ...
                         nominal_other_tile_offset_ijk, ...
                         border_central_tile_landmarks_ijk, border_other_tile_landmarks_ijk, ...
                         matched_central_tile_landmarks_ijk, matched_other_tile_landmarks_ijk, ...
                         central_tile_relative_path, ...
                         other_tile_relative_path, ...
                         matching_channel_index) ;
end



function result = unflip_stack_as_needed(maybe_flipped_stack_jik, tile_flip_metadata)
    result = maybe_flipped_stack_jik ;
    if tile_flip_metadata.is_x_flipped ,
        result = fliplr(result) ;
    end
    if tile_flip_metadata.is_y_flipped ,
        result = flipud(result) ;
    end    
end
