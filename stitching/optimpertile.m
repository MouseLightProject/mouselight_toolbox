function [targets_at_cpg_k_indices_3_and_4, ...
          other_tile_targets_at_cpg_k_indices_1_and_2, ...
          new_k0_from_cpg_k_index, ...
          new_other_tile_k0_from_cpg_k_index] = ...
        optimpertile(tile_index, ...
                     params, ...
                     other_tile_index, ...
                     affine_transform_from_tile_index, ...
                     match_z_statistics_from_tile_index, ...
                     k0_from_cpg_k_index_from_tile_index, ...
                     field_corrected_cpg_ij0s, ...
                     Fx_layer, ...
                     Fy_layer, ...
                     Fz_layer, ...
                     Fx_next_layer, ...
                     Fy_next_layer, ...
                     Fz_next_layer, ...
                     default_k0_from_cpg_k_index)
    % The other_tile_index shold be the index of the z+1 tile, or nan if there is no such tile.                              
                 
    % In all that follows, "CPG" means "control point grid".
    
    % Break out parameters
    htop = params.htop ;  % the 1st CPG z plane is offset from the 2nd by this amount
    cpg_k_count = params.Nlayer ;  % Number of k/z values in the per-tile control point grid (traditionally 4)    
    %cpg_i_count = params.Ndivs+1 ;  % Number of i/x values in the per-tile control point grid (traditionally 5)
    %cpg_j_count = params.Ndivs+1 ;  % Number of j/y values in the per-tile control point grid (traditionally 5)        
    %cpg_ij_count = cpg_i_count * cpg_j_count ;  % Number of points in each k/z layer in the per-tile control point grid (traditionally 25)
    tile_shape_ijk = params.imagesize ;  % tile shape, in xyz order (traditionally [1024 1536 251])
    %order = params.order ;  % order of the field curvature model, I think
    do_correct_targets = true ;  % I guess can be set to false for debugging?

    % Break out things for this tile and the other tile (the k+1 tile)
    affine_transform = affine_transform_from_tile_index(:,:,tile_index) ;
    match_z_statistics = match_z_statistics_from_tile_index(tile_index,:) ;  % [idxt  idxtp1 med[idxt,idxtp1] min[idxt,idxtp1] max[idxt,idxtp1]];
    old_k0_from_cpg_k_index = k0_from_cpg_k_index_from_tile_index(:,tile_index) ;
    if isnan(other_tile_index) ,
        other_tile_old_k0_from_cpg_k_index = nan(cpg_k_count, 1) ;
    else
        other_tile_affine_transform = affine_transform_from_tile_index(:,:,other_tile_index) ;
        other_tile_old_k0_from_cpg_k_index = k0_from_cpg_k_index_from_tile_index(:, other_tile_index) ;
    end
    
    % Handle each of the three major cases separately
    if isnan(other_tile_index) ,  % if there is no k+1 tile
        % In this case there's no need to potentially shift the 3rd and 4th CPG z planes
        % to give good overlap with 1st and 2nd CPG z planes in the the k+1 tile.
        % So we just compute the shifted targets, using the default k/z levels for the
        % CPG planes.
        
        % Compute targets for the 3rd k/z plane of the CPG (control point grid) 
        % These are shifted by the corrections intended to get the landmark pairs into
        % register.
        new_k0_at_cpg_k_index_3 = default_k0_from_cpg_k_index(3) ;
        targets_at_cpg_k_index_3 = ...
            corrected_targets_for_single_cpg_k_plane(new_k0_at_cpg_k_index_3, ...
                                                     field_corrected_cpg_ij0s, ...
                                                     affine_transform, ...
                                                     Fx_layer, ...
                                                     Fy_layer, ...
                                                     Fz_layer, ...
                                                     do_correct_targets) ;
                                               
        % Compute targets for the 4th k/z plane of the CPG (control point grid) 
        % These are shifted by the corrections intended to get the landmark pairs into
        % register.
        new_k0_at_cpg_k_index_4 = default_k0_from_cpg_k_index(4) ;  
        targets_at_cpg_k_index_4 = ...
            corrected_targets_for_single_cpg_k_plane(new_k0_at_cpg_k_index_4, ...
                                                     field_corrected_cpg_ij0s, ...
                                                     affine_transform, ...
                                                     Fx_layer, ...
                                                     Fy_layer, ...
                                                     Fz_layer, ...
                                                     do_correct_targets) ;

        % Set the return values for this case
        new_k0_from_cpg_k_index = old_k0_from_cpg_k_index ;
        new_other_tile_k0_from_cpg_k_index = other_tile_old_k0_from_cpg_k_index ;        
        targets_at_cpg_k_indices_3_and_4 = [ targets_at_cpg_k_index_3 ; targets_at_cpg_k_index_4 ] ;
        other_tile_targets_at_cpg_k_indices_1_and_2 = [] ;
    else
        % In this case we to need to potentially shift the 3rd and 4th CPG z planes
        % to give good overlap with 1st and 2nd CPG z planes in the the k+1 tile.
        % Once we've done this, we compute the shifted targets using the (already
        % computed) interpolators.
        
        % Break out some of th z-face landmark match statistics
        % match_z_statistics: [tile_index other_tile_index median_match_z other_median_match_z min_match_z other_min_match_z max_match_z other_max_match_z]
        %median_match_z = match_z_statistics(3) ;
        %other_median_match_z = match_z_statistics(4) ;
        min_match_z = match_z_statistics(5) ;
        other_min_match_z = match_z_statistics(6) ;
        max_match_z = match_z_statistics(7) ;
        other_max_match_z = match_z_statistics(8) ;        
        
        % Use some heuristics to compute the k/z level of the 3rd and 4th CPG planes
        tile_shape_k = tile_shape_ijk(3) ;
        new_k0_at_cpg_k_index_3 = min(tile_shape_k-2, min_match_z) ;  % min(tb.dims(idxt,3)-2, so that zlim_4 is bounded by zlim3<zlim4<=dims-1
        % bot2: then get bottom of overlap on layer tm1
        % (4)
        new_k0_at_cpg_k_index_4 = min(tile_shape_k-1, max(new_k0_at_cpg_k_index_3+1, max_match_z)) ;  % -2, as -1 results in error due to a bug in render
        if new_k0_at_cpg_k_index_3 <= old_k0_from_cpg_k_index(2) ,  % means that a tile is fully covered by the two adjacent tiles
            % @@ HEURISTIC
            new_k0_at_cpg_k_index_2 = max(1,new_k0_at_cpg_k_index_3-1) ;
            new_k0_at_cpg_k_index_1 = max(0,new_k0_at_cpg_k_index_3-6) ;
        else
            new_k0_at_cpg_k_index_2 = old_k0_from_cpg_k_index(2) ;
            new_k0_at_cpg_k_index_1 = old_k0_from_cpg_k_index(1) ;            
        end

        % Compute the targets at 3rd CPG k/z plane
        targets_at_cpg_k_index_3 = ...
            corrected_targets_for_single_cpg_k_plane(new_k0_at_cpg_k_index_3, ...
                                                     field_corrected_cpg_ij0s, ...
                                                     affine_transform, ...
                                                     Fx_layer, ...
                                                     Fy_layer, ...
                                                     Fz_layer, ...
                                                     do_correct_targets) ;

        % Compute the targets at 4th CPG k/z plane
        targets_at_cpg_k_index_4 = ...
            corrected_targets_for_single_cpg_k_plane(new_k0_at_cpg_k_index_4, ...
                                                     field_corrected_cpg_ij0s, ...
                                                     affine_transform, ...
                                                     Fx_layer, ...
                                                     Fy_layer, ...
                                                     Fz_layer, ...
                                                     do_correct_targets) ;

        % Search for a CPG k plane in the other tile that gives us good overlap with this tile
        for other_tile_new_k0_at_cpg_k_index_2 = other_max_match_z-1 : -1 : max(1,min(other_max_match_z-1,other_min_match_z)) ,
            % Compute the targets at 2nd CPG k/z plane
            other_tile_targets_at_cpg_k_index_2 = ...
                corrected_targets_for_single_cpg_k_plane(other_tile_new_k0_at_cpg_k_index_2, ...
                                                         field_corrected_cpg_ij0s, ...
                                                         other_tile_affine_transform, ...
                                                         Fx_next_layer, ...
                                                         Fy_next_layer, ...
                                                         Fz_next_layer, ...
                                                         do_correct_targets) ;
            
            % make sure that there is overlap for all target points
            if all(targets_at_cpg_k_index_4(:,3) > other_tile_targets_at_cpg_k_index_2(:,3)) ,
                break
            end
        end
        
        % In the other tile, set the 1st CPG k/x plane to be at a set offset from the
        % 2nd plane, but not below zero.
        other_tile_new_k0_at_cpg_k_index_1 = max(0, other_tile_new_k0_at_cpg_k_index_2-htop) ;
        other_tile_targets_at_cpg_k_index_1 = ...
            corrected_targets_for_single_cpg_k_plane(other_tile_new_k0_at_cpg_k_index_1, ...
                                                     field_corrected_cpg_ij0s, ...
                                                     other_tile_affine_transform, ...
                                                     Fx_next_layer, ...
                                                     Fy_next_layer, ...
                                                     Fz_next_layer, ...
                                                     do_correct_targets) ;

        % Set the return values
        new_other_tile_k0_from_cpg_k_index = ...
            [ other_tile_new_k0_at_cpg_k_index_1 ; other_tile_new_k0_at_cpg_k_index_2 ; other_tile_old_k0_from_cpg_k_index(3:4)] ;        
        new_k0_from_cpg_k_index = [ new_k0_at_cpg_k_index_1 ; new_k0_at_cpg_k_index_2 ; new_k0_at_cpg_k_index_3 ; new_k0_at_cpg_k_index_4] ;
        targets_at_cpg_k_indices_3_and_4 = [ targets_at_cpg_k_index_3 ; targets_at_cpg_k_index_4 ] ;
        other_tile_targets_at_cpg_k_indices_1_and_2 = [other_tile_targets_at_cpg_k_index_1;other_tile_targets_at_cpg_k_index_2];
    end
end



