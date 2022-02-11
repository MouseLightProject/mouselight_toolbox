function [match_struct, ...
          shift_axis_index, ...
          nominal_other_tile_ijk_offset, ...
          ijk_from_central_tile_border_landmark_index, ...
          ijk_from_other_tile_border_landmark_index] = ...
        pointmatch_core(flipped_central_tile_ijk_and_descriptors_from_landmark_index, ...
                        flipped_other_tile_ijk_and_descriptors_from_landmark_index, ...
                        central_tile_scope_struct, ...
                        other_tile_scope_struct, ...
                        manual_nominal_other_tile_ijk_offset, ...
                        maximum_landmark_count, ...
                        central_tile_ijk1)
    
    % Version of pointmatch that does the core computation, and doesn't touch the
    % filesystem.
        
    % Deal with arguments
    if ~exist('manual_nominal_other_tile_ijk_offset', 'var') || isempty(manual_nominal_other_tile_ijk_offset) ,
        manual_nominal_other_tile_ijk_offset = [] ;
    end
    if ~exist('maximum_landmark_count', 'var') || isempty(maximum_landmark_count) ,
        maximum_landmark_count=1e3 ;
    end
    if ~exist('central_tile_ijk1', 'var') || isempty(central_tile_ijk1) ,
        central_tile_ijk1 = [nan nan nan] ;
    end

    % Specify some constants
    stack_shape_ijk = [ 1024 1536 251 ] ;
    projection_threshold = 5 ;
    is_in_debug_mode = 0 ;

    % Get the stack shape in real units
    stack_shape_xyz = ...
        [ central_tile_scope_struct.x_size_um central_tile_scope_struct.y_size_um central_tile_scope_struct.z_size_um ] ;  % um
    
    % Figure out the shift axis
    other_tile_lattice_ijk_offset = ...
        [other_tile_scope_struct.x other_tile_scope_struct.y other_tile_scope_struct.z] - ...
        [central_tile_scope_struct.x central_tile_scope_struct.y central_tile_scope_struct.z] ;
    shift_axis_index = find(other_tile_lattice_ijk_offset) ;

    % Estimate translation, unless already supplied
    if isempty(manual_nominal_other_tile_ijk_offset) ,
        nominal_other_tile_xyz_offset = ...
            1000 * ...
            ([other_tile_scope_struct.x_mm other_tile_scope_struct.y_mm other_tile_scope_struct.z_mm] - ...
             [central_tile_scope_struct.x_mm central_tile_scope_struct.y_mm central_tile_scope_struct.z_mm]) ;  % um
        nominal_other_tile_ijk_offset = round(nominal_other_tile_xyz_offset .* (stack_shape_ijk-1)./stack_shape_xyz) ;
    else
        nominal_other_tile_ijk_offset = manual_nominal_other_tile_ijk_offset ;
    end

    % Early return if there are no landmarks at all
    if isempty(flipped_central_tile_ijk_and_descriptors_from_landmark_index) || isempty(flipped_other_tile_ijk_and_descriptors_from_landmark_index) ,
        match_rate = 0 ;
        central_tile_ijk_from_match_index = zeros(0,3) ;
        other_tile_ijk_from_match_index = zeros(0,3) ;
        uni = 0 ;
        was_increase_shift_warning_hit = false ;
        match_struct = new_match_struct(match_rate, central_tile_ijk_from_match_index, other_tile_ijk_from_match_index, uni, was_increase_shift_warning_hit) ;
        ijk_from_central_tile_border_landmark_index = zeros(0,3) ;
        ijk_from_other_tile_border_landmark_index = zeros(0,3) ;
        return
    end

    % correct images, xy flip
    central_tile_ijk_and_descriptors_from_landmark_index = correctTiles(flipped_central_tile_ijk_and_descriptors_from_landmark_index, stack_shape_ijk) ;
    other_tile_ijk_and_descriptors_from_landmark_index = correctTiles(flipped_other_tile_ijk_and_descriptors_from_landmark_index, stack_shape_ijk) ;

    % truncate descriptors
    central_tile_ijk_and_descriptors_from_landmark_index = truncateDesc(central_tile_ijk_and_descriptors_from_landmark_index, maximum_landmark_count) ;
    other_tile_ijk_and_descriptors_from_landmark_index = truncateDesc(other_tile_ijk_and_descriptors_from_landmark_index, maximum_landmark_count) ;

    % Another early return if truncating the landmarks has left us with none
    if isempty(central_tile_ijk_and_descriptors_from_landmark_index) || isempty(other_tile_ijk_and_descriptors_from_landmark_index) ,
        match_rate = 0 ;
        central_tile_ijk_from_match_index = zeros(0,3) ;
        other_tile_ijk_from_match_index = zeros(0,3) ;
        uni = 0 ;
        was_increase_shift_warning_hit = false ;
        match_struct = new_match_struct(match_rate, central_tile_ijk_from_match_index, other_tile_ijk_from_match_index, uni, was_increase_shift_warning_hit) ;
        ijk_from_central_tile_border_landmark_index = zeros(0,3) ;
        ijk_from_other_tile_border_landmark_index = zeros(0,3) ;
        return
    end

%     if length(shift_axis_index)~=1 || max(shift_axis_index)>3 ,
%         error('not 6 direction neighbor') ;
%     end

    % Try matching with searchpair()
    matching_parameters = modelParams(projection_threshold, is_in_debug_mode) ;
    [central_tile_ijk_from_match_index, ...
     other_tile_ijk_from_match_index, ...
     match_rate, ...
     ~, ...
     nonuniformity, ...
     was_increase_shift_warning_hit, ...
     ijk_from_central_tile_border_landmark_index, ...
     ijk_from_other_tile_border_landmark_index] = ...
        searchpair(central_tile_ijk_and_descriptors_from_landmark_index, ...
                   other_tile_ijk_and_descriptors_from_landmark_index, ...
                   nominal_other_tile_ijk_offset, ...
                   shift_axis_index, ...
                   stack_shape_ijk, ...
                   matching_parameters, ...
                   central_tile_ijk1) ;

    % If that failed, try searchpair_relaxed()       
    if isempty(central_tile_ijk_from_match_index) ,
        % If get here, searchpair() failed, so we try searchpair_relaxed(), which takes
        % slightly different arguments.
        relaxed_matching_parameters = matching_parameters ;
        relaxed_matching_parameters.opt.outliers = 0.5 ;
        central_tile_ijk_from_landmark_index = central_tile_ijk_and_descriptors_from_landmark_index(:, 1:3) ;
        other_tile_ijk_from_landmark_index = other_tile_ijk_and_descriptors_from_landmark_index(:, 1:3) ;                
        [central_tile_ijk_from_match_index, ...
         other_tile_ijk_from_match_index, ...
         match_rate, ...
         ~, ...
         nonuniformity, ...
         ijk_from_central_tile_border_landmark_index, ...
         ijk_from_other_tile_border_landmark_index] = ...
            searchpair_relaxed(central_tile_ijk_from_landmark_index, ...
                               other_tile_ijk_from_landmark_index, ...
                               nominal_other_tile_ijk_offset, ...
                               shift_axis_index, ...
                               stack_shape_ijk, ...
                               relaxed_matching_parameters);
    end

    flipped_central_tile_ijk_from_match_index = correctTiles(central_tile_ijk_from_match_index, stack_shape_ijk) ;
    flipped_other_tile_ijk_from_match_index = correctTiles(other_tile_ijk_from_match_index, stack_shape_ijk) ;
    uni = (mean(nonuniformity)<=0.5) ;

    % Package things up in struct to return
    match_struct = ...
        new_match_struct(match_rate, ...
                         flipped_central_tile_ijk_from_match_index, ...
                         flipped_other_tile_ijk_from_match_index, ...
                         uni, ...
                         was_increase_shift_warning_hit) ;
end
