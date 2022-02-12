function [targets_from_tile_index, cpg_k0_values_from_tile_index, tile_k_from_run_layer_index] = ...
        compute_targets_from_z_matches(baseline_targets_from_tile_index, ...
                                       do_cold_stitch, ...
                                       regpts, ...
                                       cpg_ij1s, ...
                                       default_cpg_k0_values, ...
                                       scopeloc, ...
                                       scopeparams, ...
                                       has_k_plus_1_tile_from_tile_index, ...
                                       tile_ijk_from_tile_index, ...
                                       curvemodel, ...
                                       baseline_affine_transform_from_tile_index, ...
                                       tile_ij1s, ...
                                       tileneighbors, ...
                                       params, ...
                                       do_apply_field_correction)
                                   
    % Get some dimensions                                   
    tile_count = length(scopeloc.filepath) ;
    cpg_i_count = params.Ndivs+1 ;  % Number of i/x values in the per-tile control point grid (traditionally 5)
    cpg_j_count = params.Ndivs+1 ;  % Number of j/y values in the per-tile control point grid (traditionally 5)    
    cpg_ij_count = cpg_i_count * cpg_j_count ;  % Number of points in each k/z layer in the per-tile control point grid (traditionally 25)    
    
    % The first pass of the z planes of the control points, for each tile
    % If a cold stitch, these will also be the final pass values.
    targets_from_tile_index = baseline_targets_from_tile_index ;    
    baseline_cpg_k0_values_from_tile_index = repmat(default_cpg_k0_values', [1 tile_count]) ;
    tile_k_from_tile_index = tile_ijk_from_tile_index(:,3) ;  % column
    tile_k_from_layer_index = unique(tile_k_from_tile_index) ;  % layer of tiles, that is
    tile_k_from_run_layer_index = tile_k_from_layer_index(1:end-1)' ;  % a "run layer" is a layer that will actually be run
    cpg_k0_values_from_tile_index = baseline_cpg_k0_values_from_tile_index ;

    % If a cold stitch, exit early
    if do_cold_stitch ,
        return
    end
    
    % Collect some information about the point correspondences for each tile
    has_zero_z_face_matches_from_tile_index = false(tile_count,1) ;
    match_statistics = nan(tile_count, 8) ;
    for tile_index = 1 : tile_count ,
        % pix stats
        this_tile_regpts = regpts{tile_index} ;
        match_coords = this_tile_regpts.X ;  % match_count x 3, the coordinates of matched landmarks in this tile
        if isempty(match_coords) ,
            has_zero_z_face_matches_from_tile_index(tile_index) = true ;
            continue
        end
        match_coords_in_neighbor = this_tile_regpts.Y ;  % match_count x 3, the coordinates of matched landmarks in the z+1 tile, in same order as layer
        match_z_in_both_tiles = [ match_coords(:,3) match_coords_in_neighbor(:,3) ] ;  % match_count x 2
        median_match_z_in_both_tiles = round(median(match_z_in_both_tiles,1)) ; % 1x2
        min_match_z_in_both_tiles = round(min(match_z_in_both_tiles,[],1)) ; % 1x2
        max_match_z_in_both_tiles = round(max(match_z_in_both_tiles,[],1)) ; % 1x2
        tile_index_of_z_plus_1_tile = this_tile_regpts.neigs(4) ;
        match_statistics(tile_index,:) = ...
            [ tile_index  tile_index_of_z_plus_1_tile ...
              median_match_z_in_both_tiles min_match_z_in_both_tiles max_match_z_in_both_tiles ] ;
    end   
    
    % Sort out which we'll run with which thing
    % The tiles we run with optimpertile are "anchors".
    % The tiles we run with nomatchoptim are "floaters".
    is_floater_from_tile_index = has_k_plus_1_tile_from_tile_index & has_zero_z_face_matches_from_tile_index ;
    is_anchor_from_tile_index = ~is_floater_from_tile_index ;
    
    % Make an interpolator for each z layer, use it to shift the control point
    % targets for the tiles in the layer, and the z+1 layer
    run_layer_count = length(tile_k_from_run_layer_index) ;
    for run_layer_index = 1 : run_layer_count ,
        % Sort out which tiles are in this layer
        tile_k = tile_k_from_run_layer_index(run_layer_index) ;
        fprintf('    Layer %d of %d, tile k/z = %d\n', run_layer_index, run_layer_count, tile_k);
        is_in_this_layer_from_tile_index = (tile_k_from_tile_index'==tile_k) ;
        tile_index_from_layer_tile_index = find(is_in_this_layer_from_tile_index);
        if isempty(tile_index_from_layer_tile_index) ,
            fprintf('No tiles found in layer with tile k/z = %d!!\n', tile_k) ;
            continue
        end
        
        % get interpolants based on paired descriptors
        [Fx_layer, Fy_layer, Fz_layer, Fx_next_layer, Fy_next_layer, Fz_next_layer, XYZ_original, XYZ_neighbor_original, outliers] =...
            util.getInterpolants(tile_index_from_layer_tile_index, ...
                                 regpts, ...
                                 baseline_affine_transform_from_tile_index, ...
                                 tile_ij1s, ...
                                 params, ...
                                 curvemodel, ...
                                 do_apply_field_correction) ;

        % Show some debugging output if called for
        if params.debug ,
            vector_field_3d_debug_script(scopeloc, scopeparams, params, XYZ_original, XYZ_neighbor_original, outliers) ;
        end
        
        % If too few matched landmarks, don't proceed with this layer
        if isempty(Fx_layer) || size(Fx_layer.Points,1) < 10 ,
            fprintf('    Layer with k/z = %d has too few matches to proceed.\n', tile_k) ;            
            continue
        end
        
        % Print the number of matches in this layer
        layer_used_match_count = size(Fx_layer.Points,1) ;
        fprintf('    Layer with k/z = %d total used matches: %d\n', tile_k, layer_used_match_count) ;
        
        % Go through all the tiles which either have no z+1 tile or for which we have
        % nonzero z-face matches, and optimize the CPG for each.  Then, compute the
        % target values for the moved z-planes of the CPG, using the interpolators to
        % try to make the matched pairs each go to the same point.
        is_anchor_from_layer_tile_index = is_anchor_from_tile_index(tile_index_from_layer_tile_index) ;
        tile_index_from_layer_anchor_index = tile_index_from_layer_tile_index(is_anchor_from_layer_tile_index) ;
        for tile_index = tile_index_from_layer_anchor_index ,
            neighbor_tile_index = tileneighbors(tile_index, 7) ;  % the z+1 tile

            if do_apply_field_correction ,
                this_tile_curve_model = curvemodel(:,:,tile_index) ;
                field_corrected_cpg_ij1s = util.fcshift(this_tile_curve_model, order, tile_ij1s, tile_shape_ijk, cpg_ij1s) ;
            else
                field_corrected_cpg_ij1s = cpg_ij1s ;
            end
            field_corrected_cpg_ij0s = field_corrected_cpg_ij1s - 1 ;

            [targets_at_cpg_k_indices_3_and_4, ...
             other_tile_targets_at_cpg_k_indices_1_and_2, ...
             new_cpg_k0_values, ...
             k_plus_1_tile_cpg_k0_values] = ...
                optimpertile(tile_index, ...
                             params, ...
                             neighbor_tile_index, ...
                             baseline_affine_transform_from_tile_index, ...
                             match_statistics, ...
                             cpg_k0_values_from_tile_index, ...
                             field_corrected_cpg_ij0s, ...
                             Fx_layer, ...
                             Fy_layer, ...
                             Fz_layer, ...
                             Fx_next_layer, ...
                             Fy_next_layer, ...
                             Fz_next_layer, ...
                             default_cpg_k0_values) ;
            cpg_k0_values_from_tile_index(:,tile_index) = new_cpg_k0_values ;
            if ~isnan(neighbor_tile_index) ,
                cpg_k0_values_from_tile_index(:,neighbor_tile_index) = k_plus_1_tile_cpg_k0_values ;
            end
            targets_from_tile_index(2*cpg_ij_count+1:end,:,tile_index) = targets_at_cpg_k_indices_3_and_4 ;
            if ~isempty(other_tile_targets_at_cpg_k_indices_1_and_2) ,
                targets_from_tile_index(1:2*cpg_ij_count,:,neighbor_tile_index) = other_tile_targets_at_cpg_k_indices_1_and_2 ;
            end
        end  % for tile_index = ...
        
        % Get the tile ijk indices of the anchors and the floaters
        is_floater_from_tile_within_layer_index = is_floater_from_tile_index(tile_index_from_layer_tile_index) ;
        tile_index_from_layer_floater_index = tile_index_from_layer_tile_index(is_floater_from_tile_within_layer_index) ;
        layer_floater_count = length(tile_index_from_layer_floater_index) ;
        tile_ijk_from_layer_anchor_index = tile_ijk_from_tile_index(tile_index_from_layer_anchor_index,:) ;        
        tile_ijk_from_layer_floater_index = tile_ijk_from_tile_index(tile_index_from_layer_floater_index,:) ;
        
        % Build an index of the closest anchor tile to each floater tile
        nearest_layer_anchor_index_from_layer_floater_index = knnsearch(tile_ijk_from_layer_anchor_index,tile_ijk_from_layer_floater_index,'K',1) ;
        
        % Build an index of all the anchor tiles in the "18-neighborhood" of each
        % floater tile.  If that set is empty for any floater tile, augment with
        % whatver the nearest anchor tile is.
        nearby_layer_anchor_indices_from_layer_floater_index = rangesearch(tile_ijk_from_layer_anchor_index,tile_ijk_from_layer_floater_index,sqrt(2)) ;
            % "nearby" here seems to mean not the 6-neighborhood nor the 26-neighborhood, but
            % the 18-neighborhood: All the neighbors that differ by 1 in at most 2
            % dimensions.  So the whole rubick's cube (3^3==27), minus self (-1), minus the
            % corners (-8).  So 27-1-8==18, the '18-neighborhood'.
        for layer_floater_index = 1 : layer_floater_count ,
            layer_anchor_index_from_nearby_tile_index = nearby_layer_anchor_indices_from_layer_floater_index{layer_floater_index} ;
            if isempty(layer_anchor_index_from_nearby_tile_index) ,
                nearby_layer_anchor_indices_from_layer_floater_index{layer_floater_index} = ...
                    nearest_layer_anchor_index_from_layer_floater_index(layer_floater_index);
            end
        end
        
        % For each floater tile, optimize its CPG and recompute targets, if needed
        for layer_floater_index = 1 : layer_floater_count ,
            % Get the tile index, and the z+1 tile index 
            tile_index = tile_index_from_layer_floater_index(layer_floater_index) ;            
            neighbor_tile_index = tileneighbors(tile_index,7) ;  % the z/k+1 tile
            
            % Get a fallback value for the CPG k0/z levels, by taking the median of the the
            % CPG k0 values for the nearby anchor tiles.
            layer_anchor_index_from_nearby_tile_index = nearby_layer_anchor_indices_from_layer_floater_index{layer_floater_index} ;            
            tile_index_from_nearby_tile_index = tile_index_from_layer_anchor_index(layer_anchor_index_from_nearby_tile_index) ;
            cpg_k0_values_from_nearby_tile_index = cpg_k0_values_from_tile_index(:,tile_index_from_nearby_tile_index) ;
            local_default_cpg_k0_values = round(median(cpg_k0_values_from_nearby_tile_index,2))' ;

            [targets_at_cpg_k_indices_3_and_4, ...
             other_tile_targets_at_cpg_k_indices_1_and_2, ...
             new_cpg_k0_values, ...
             k_plus_1_tile_cpg_k0_values] = ...
                nomatchoptim(tile_index, ...
                             params, ...
                             neighbor_tile_index, ...
                             baseline_affine_transform_from_tile_index, ...
                             match_statistics, ...
                             cpg_k0_values_from_tile_index(:,tile_index), ...
                             cpg_k0_values_from_tile_index(:,neighbor_tile_index), ...
                             field_corrected_cpg_ij0s, ...
                             Fx_layer, ...
                             Fy_layer, ...
                             Fz_layer, ...
                             Fx_next_layer, ...
                             Fy_next_layer, ...
                             Fz_next_layer, ...
                             local_default_cpg_k0_values) ;
            cpg_k0_values_from_tile_index(:,tile_index) = new_cpg_k0_values ;
            cpg_k0_values_from_tile_index(:,neighbor_tile_index) = k_plus_1_tile_cpg_k0_values ;
            targets_from_tile_index(2*cpg_ij_count+1:end,:,tile_index) = targets_at_cpg_k_indices_3_and_4 ;
            targets_from_tile_index(1:2*cpg_ij_count,:,neighbor_tile_index) = other_tile_targets_at_cpg_k_indices_1_and_2 ;
        end
    end  % for loop over layers
end