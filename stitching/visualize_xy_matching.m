function visualize_xy_matching(central_tile_stack_jik, other_tile_stack_jik, ...
                               central_tile_landmarks_ijk, other_tile_landmarks_ijk, ...
                               nominal_other_tile_offset_ijk, ...
                               border_central_tile_landmarks_ijk, border_other_tile_landmarks_ijk, ...
                               matched_central_tile_landmarks_ijk, matched_other_tile_landmarks_ijk)
    % Tool for visualizing matching between x-neighbors and y-neighbors.
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

    % Collapse the stacks down to MIPs
    central_mip = max(central_tile_stack_jik,[],3) ;  % x in dimension 2, y in dimension 1, as per Matlab convention for images
    other_mip = max(other_tile_stack_jik,[],3) ;
    
    % Shift landmarks from the other tile into the coordinate system of the
    % central tile
    shifted_other_tile_landmarks_ijk = other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;
    shifted_border_other_tile_landmarks_ijk = border_other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;
    shifted_matched_other_tile_landmarks_ijk = matched_other_tile_landmarks_ijk + nominal_other_tile_offset_ijk ;

    % Make a reference frame for each time, for handling to imshowpair()
    central_reference_frame = imref2d(size(central_mip),[1 stack_shape_ijk(1)],[1 stack_shape_ijk(2)]);
    if shifted_axis_index == 1 ,
        other_reference_frame = imref2d(size(other_mip),[1 stack_shape_ijk(1)]+nominal_other_tile_offset_ijk(1),[1 stack_shape_ijk(2)]);
    else
        other_reference_frame = imref2d(size(other_mip),[1 stack_shape_ijk(1)],[1 stack_shape_ijk(2)]+nominal_other_tile_offset_ijk(2));
    end
    
    %
    % Make the figure
    %
    
    if isempty(fig) || ~isvalid(fig),
        fig = figure('Color', 'w', 'Name', mfilename()) ;
    end
    clf(fig) ;
    ax = axes(fig) ;
    imshowpair(imadjust(central_mip), ...
               central_reference_frame, ...
               imadjust(other_mip), ...
               other_reference_frame, ...
               'Parent', ax, ...
               'falsecolor', ...
               'Scaling','joint', ...
               'ColorChannels','green-magenta') ;
    hold(ax,'on') ;
    % Show all landmarks as small circles
    myplot3pp(ax, central_tile_landmarks_ijk-1, 'bo', 'MarkerSize', 6, 'LineWidth', 1) ;
    myplot3pp(ax, shifted_other_tile_landmarks_ijk-1, 'yo', 'MarkerSize', 6, 'LineWidth', 1) ;
    % Show border landmarks as larger circles
    myplot3pp(ax, border_central_tile_landmarks_ijk-1, 'bo', 'MarkerSize', 12, 'LineWidth', 1) ;
    myplot3pp(ax, shifted_border_other_tile_landmarks_ijk-1, 'yo', 'MarkerSize', 12, 'LineWidth', 1) ;
    % Draw a line between the matched landmarks
    i_from_partner_index_from_match_index = [matched_central_tile_landmarks_ijk(:,1), shifted_matched_other_tile_landmarks_ijk(:,1)]'-1 ;
    j_from_partner_index_from_match_index = [matched_central_tile_landmarks_ijk(:,2), shifted_matched_other_tile_landmarks_ijk(:,2)]'-1 ;
      % The "partner index" is 1 for the central tile, 2 for the other tile
    plot(ax, i_from_partner_index_from_match_index, j_from_partner_index_from_match_index, 'r') ;
    hold(ax,'off') ;
    drawnow
end
