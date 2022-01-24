function visualize_z_matching(central_tile_stack_jik, other_tile_stack_jik, ...
                              central_tile_landmarks_ijk, other_tile_landmarks_ijk, ...
                              nominal_other_tile_offset_ijk, ...
                              border_central_tile_landmarks_ijk, border_other_tile_landmarks_ijk, ...
                              matched_central_tile_landmarks_ijk, matched_other_tile_landmarks_ijk, ...
                              central_tile_relative_path, ...
                              other_tile_relative_path, ...
                              matching_channel_index)
                          
    % Tool for visualizing matching between z-neighbors.
    % This is sort of a "core" function, assuming all the flipping and swapping
    % required for MouseLight samples is already done, and the tile stacks
    % are oriented as they would be in Janelia Workstation.
    
    % We want to re-use the figure beween calls
    persistent fig

    % Get the stack shape
    stack_shape_jik = size(central_tile_stack_jik);  % like yxz, but in pixels
    stack_shape_ijk = stack_shape_jik([2 1 3]) ;  % like xyz, but in pixels

    % nominal_other_tile_offset_ijk will typically only have one non-zero
    % element.  Determine which axis contains the non-zero element.
    [~,shifted_axis_index] = max(abs(nominal_other_tile_offset_ijk)) ;
    if shifted_axis_index ~= 3 ,
        error('%s() should only be used to visualize matching between z-neighbor tiles', mfilename()) ;
    end
    
    % Collapse the stacks down to MIPs
    central_mip_jik = max(central_tile_stack_jik,[],1) ;  % collapse y
    central_mip_ki = reshape(central_mip_jik, [stack_shape_jik(2) stack_shape_jik(3)])' ;  % keep x in x, put z in y
    other_mip_jik = max(other_tile_stack_jik,[],1) ;
    other_mip_ki = reshape(other_mip_jik, [stack_shape_jik(2) stack_shape_jik(3)])' ;    
    
    % Shift landmarks from the other tile into the coordinate system of the
    % central tile
    shifted_other_tile_landmarks_ijk = other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;
    shifted_border_other_tile_landmarks_ijk = border_other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;
    shifted_matched_other_tile_landmarks_ijk = matched_other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;

    % Make a reference frame for each stack, for handling to imshowpair()
    central_reference_frame = imref2d(size(central_mip_ki), ...
                                      [0.5 stack_shape_ijk(1)+0.5], ...
                                      [0.5 stack_shape_ijk(3)]+0.5) ;
    other_reference_frame = imref2d(size(other_mip_ki), ...
                                    [0.5 stack_shape_ijk(1)+0.5], ...
                                    [0.5 stack_shape_ijk(3)+0.5]+nominal_other_tile_offset_ijk(3)) ;

    % Get rid of y dim in landmarks
    central_tile_landmarks_ik = central_tile_landmarks_ijk(:,[1 3]) ;
    shifted_other_tile_landmarks_ik = shifted_other_tile_landmarks_ijk(:,[1 3]) ;
    border_central_tile_landmarks_ik = border_central_tile_landmarks_ijk(:,[1 3]) ;
    shifted_border_other_tile_landmarks_ik = shifted_border_other_tile_landmarks_ijk(:,[1 3]) ;

    %
    % Make the figure
    %
    
    if isempty(fig) || ~isvalid(fig),
        fig = figure('Color', 'w', 'Name', mfilename()) ;
    end
    clf(fig) ;
    ax = axes(fig) ;
    imshowpair(imadjust(central_mip_ki), ...
               central_reference_frame, ...
               imadjust(other_mip_ki), ...
               other_reference_frame, ...
               'Parent', ax, ...
               'falsecolor', ...
               'Scaling','joint', ...
               'ColorChannels','green-magenta') ;
    hold(ax,'on') ;
    % Show all landmarks as small circles
    plot(ax, central_tile_landmarks_ik(:,1), central_tile_landmarks_ik(:,2), 'bo', 'MarkerSize', 6, 'LineWidth', 1) ;
    plot(ax, shifted_other_tile_landmarks_ik(:,1), shifted_other_tile_landmarks_ik(:,2), 'yo', 'MarkerSize', 6, 'LineWidth', 1) ;
    % Show border landmarks as larger circles
    plot(ax, border_central_tile_landmarks_ik(:,1), border_central_tile_landmarks_ik(:,2), 'bo', 'MarkerSize', 12, 'LineWidth', 1) ;
    plot(ax, shifted_border_other_tile_landmarks_ik(:,1), shifted_border_other_tile_landmarks_ik(:,2), 'yo', 'MarkerSize', 12, 'LineWidth', 1) ;
    % Draw a line between the matched landmarks
    i_from_partner_index_from_match_index = [matched_central_tile_landmarks_ijk(:,1), shifted_matched_other_tile_landmarks_ijk(:,1)]' ;
    k_from_partner_index_from_match_index = [matched_central_tile_landmarks_ijk(:,3), shifted_matched_other_tile_landmarks_ijk(:,3)]' ;
      % The "partner index" is 1 for the central tile, 2 for the other tile
    plot(ax, i_from_partner_index_from_match_index, k_from_partner_index_from_match_index, 'r') ;
    hold(ax,'off') ;
    xlabel(ax, 'x (voxels)') ;
    ylabel(ax, 'z (voxels)') ;
    title_string = sprintf('Central tile: %s     z+1 tile: %s      Channel %d', central_tile_relative_path, other_tile_relative_path, matching_channel_index) ;
    title(ax, title_string, 'Interpreter', 'none') ;
    drawnow
end
