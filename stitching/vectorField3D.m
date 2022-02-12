function vecfield = vectorField3D(params, scopeloc, do_cold_stitch, regpts, scopeparams, curvemodel)
    fprintf('Calculating vector fields...\n') ;
    tile_count = length(scopeloc.filepath) ;
    cpg_k_count = params.Nlayer ;  % Number of k/z values in the per-tile control point grid (traditionally 4)
    cpg_i_count = params.Ndivs+1 ;  % Number of i/x values in the per-tile control point grid (traditionally 5)
    cpg_j_count = params.Ndivs+1 ;  % Number of j/y values in the per-tile control point grid (traditionally 5)    
    cpg_ij_count = cpg_i_count * cpg_j_count ;  % Number of points in each k/z layer in the per-tile control point grid (traditionally 25)
    tile_shape_ijk = params.imagesize ;  % tile shape, in xyz order (traditionally [1024 1536 251])
    order = params.order ;  % order of the field curvature model, I think
    default_cpg_k0_values = [2 20 tile_shape_ijk(3)-20-1 tile_shape_ijk(3)-2-1] ;  
      % The z values in the control point gird (traditionally [2 20 230 248])
      % If these are symmetric, it implies that this is using zero-based indexing.
    %params.zlimdefaults = zlimdefaults;
    do_apply_field_correction = params.applyFC ;  % whether or not to apply the field correction, I think

    % Build the neighbor index
    tile_ijk_from_tile_index = scopeloc.gridix(:,1:3) ;
    tileneighbors = buildNeighbor(tile_ijk_from_tile_index) ;  % tile_count x 7, each row in [self -x -y +x +y -z +z] format
    has_k_plus_1_tile_from_tile_index = ~isnan(tileneighbors(:,7)) ;
    
    % Determine the x-y grid used for the control points of the barymetric transform
    % in the per-tile space.
    % The x-y grid a crop of the full tile x-y range, to minimize overlap between
    % tiles in the rendered space.
    [st, ed] = util.getcontolpixlocations(scopeloc, params) ;  % st 3x1, the first x/y/z lim in each dimension; ed 3x1, the last x/y/z lim in each dimension
    [cpg_ij0s, cpg_i0_values, cpg_j0_values] = ...
        util.getCtrlPts(tile_shape_ijk(1), tile_shape_ijk(2), params, st, ed) ;  % "cpg" is the "control point grid"
      % cpg_i0_values is traditionally 1 x 5, gives the i/x values used in the control
      % point grid.  Uses zero-based indexing
      % cpg_j0_values is traditionally 1 x 5, gives the j/y values used in the control
      % point grid.  Uses zero-based indexing
      % cpg_ij0s is traditionally 25 x 2, gives all the combinations of cpg_i0_values
      % and cpg_j0_values.  I.e. it's a raster-scan of the xy grid in the tile
    cpg_ij1s = cpg_ij0s + 1 ;  % traditionally 25 x 2, the ij/xy coords of the control point grid in each tile, in each z plane
    
    % Get the linear transform used for each tile
    % Need to flip the x/y dimensions in the per-tile linear transform to match
    % imaging
    if ~do_cold_stitch && do_apply_field_correction ,
        raw_linear_transform_from_tile_index = reshape([scopeparams(:).affineglFC],3,3,[]);
    else
        % Just use the nomimal linear transform
        spacing = 1000 * params.imsize_um ./ (params.imagesize-1) ;
        default_linear_transform = diag([+1 +1 -1] .* spacing) ;        
        raw_linear_transform_from_tile_index = repmat(default_linear_transform, [1 1 tile_count]) ;
    end        
    mflip = -eye(3) ;
    linear_transform_from_tile_index = zeros(size(raw_linear_transform_from_tile_index)) ;
    for ii = 1 : size(raw_linear_transform_from_tile_index,3) ,
        linear_transform_from_tile_index(:,:,ii) = raw_linear_transform_from_tile_index(:,:,ii) * mflip ;
    end

    % For efficiency reasons, precompute the grid of i,j values in each plane of the
    % tile (for all pixels, not on the control point grid)
    xlocs = 1:tile_shape_ijk(1) ;
    ylocs = 1:tile_shape_ijk(2) ;
    [xy2, xy1] = ndgrid(ylocs(:), xlocs(:)) ;
    tile_ij1s = [xy1(:), xy2(:)] ;  % tile_shape_ijk(1)*tile_shape_ijk(2) x 2, the ij1/xy coords of each pixel in a z plane of the tile stack

    % Extract the root of the raw tiles folder 
    filep = strsplit(scopeloc.filepath{1},'/') ;
    vecfield_root = fullfile('/',filep{1:end-4}) ;  % e.g. '/groups/mousebrainmicro/mousebrainmicro/data/2020-09-15/Tiling'

    % Get the relative path to each tile from scopeloc
    vecfield_path = cell(1, tile_count) ;
    for tile_index = 1 : tile_count ,
        filepath = fileparts(scopeloc.filepath{tile_index}) ;
        vecfield_path{tile_index} = filepath(length(vecfield_root)+1:end) ;  % e.g. '/2020-09-25/00/00000'
    end
    
    % Compute the baseline affine transform for each tile
    baseline_affine_transform_from_tile_index = zeros(3, 4, tile_count) ;  % nm
    for tile_index = 1 : tile_count ,
        % form an affine matrix
        linear_transform = linear_transform_from_tile_index(:,:,tile_index) ;  % nm
        nominal_tile_offset_in_mm = scopeloc.loc(tile_index,:) ;  % 1x3, mm
        nominal_tile_offset_in_nm = 1e6 * nominal_tile_offset_in_mm ;  % 1x3, nm        
        baseline_affine_transform = [linear_transform nominal_tile_offset_in_nm'] ;  % nm
        baseline_affine_transform_from_tile_index(:,:,tile_index) = baseline_affine_transform ;
    end

    % Compute the first pass as the control point targets in the rendered space
    baseline_targets_from_tile_index = zeros(cpg_ij_count*cpg_k_count, 3, tile_count) ;  % Location of each control point in the rendered space, for each tile
    for tile_index = 1 : tile_count ,
        % field curvature
        if ~do_cold_stitch && do_apply_field_correction ,
            this_tile_curve_model = curvemodel(:,:,tile_index) ;
            field_corrected_cpg_ij1s = util.fcshift(this_tile_curve_model, order, tile_ij1s, tile_shape_ijk, cpg_ij1s) ;
                % 25 x 2, one-based ij coordinates, but non-integral
        else
            field_corrected_cpg_ij1s = cpg_ij1s ;
        end
        field_corrected_cpg_ij0s = field_corrected_cpg_ij1s - 1 ; % 25 x 2, zero-based ij coordinates, but non-integral

        % Get the affine transform
        baseline_affine_transform = baseline_affine_transform_from_tile_index(:,:,tile_index) ;
        
        % Compute the initial targets at each z plane of the control point grid
        targets_from_cpg_k_index = zeros(cpg_ij_count, 3, cpg_k_count) ;        
        for cpg_k_index = 1 : cpg_k_count ,
            field_corrected_cpg_ijk0s = zeros(cpg_ij_count, 3) ;
            field_corrected_cpg_ijk0s(:,1:2) = field_corrected_cpg_ij0s ;
            field_corrected_cpg_ijk0s(:,3) = default_cpg_k0_values(cpg_k_index) ;
            targets_at_this_cpg_k_index = add_ones_column(field_corrected_cpg_ijk0s) * baseline_affine_transform' ;
            targets_from_cpg_k_index(:, :, cpg_k_index) = targets_at_this_cpg_k_index ;
        end                   

        % Stuff it all into the baseline_targets_from_tile_index array
        %targets = reshape(targets_from_cpg_k_index, [cpg_ij_count*cpg_k_count 3]) ;
        %  ^ this gets the order wrong        
        targets = zeros(cpg_ij_count*cpg_k_count,3) ;
        offset = 0 ;
        for cpg_k_index = 1 : cpg_k_count ,
            targets(offset+1:offset+cpg_ij_count,:) = targets_from_cpg_k_index(:,:,cpg_k_index) ;
            offset = offset + cpg_ij_count ;
        end        
        baseline_targets_from_tile_index(:, :, tile_index) = targets ;
    end
    
    % Use the matching points to compute the final targets for each control point,
    % in each tile.
    [targets_from_tile_index, cpg_k0_values_from_tile_index, tile_k_from_run_layer_index] = ...
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
                                       do_apply_field_correction) ;   
    
    % Compute bounding boxes for each tile
    bbox = zeros(8,3,tile_count) ;
    origin = zeros(tile_count,3) ; 
    sz = zeros(tile_count,3) ;
    for tile_index = 1 : tile_count ,
        targets = targets_from_tile_index(:,:,tile_index) ;
        [bbox(:,:,tile_index), origin(tile_index,:), sz(tile_index,:)] = ...
            util.bboxFromCorners(targets) ;
    end
    
    % Update per-tile affine transforms based on control points
    fprintf('Updating per-tile affine transforms based on control point targets...\n')
    final_affine_transform_from_tile_index = zeros(5, 5, tile_count) ;
    numX = size(targets_from_tile_index(:,:,1),1) ;
    for tile_index = 1 : tile_count ,
        X = targets_from_tile_index(:,:,tile_index)'/1000 ;  % /1000 converts nm to um (why? numerical stability?)
        x = cpg_i0_values ;
        y = cpg_j0_values ;
        z = cpg_k0_values_from_tile_index(:,tile_index)' ;
        [xx,yy,zz] = ndgrid(x,y,z) ;
        r = [xx(:),yy(:),zz(:)]' ;
        X_aug = [X;ones(1,numX)] ;
        r_aug = [r;ones(1,numX)] ;
        %A = (X*x')/(x*x');
        A = X_aug/r_aug ;  % 4x4, Compute a single transform that approximates, as best it can, the mapping implied by all the control-point to target pairs.
        A_full = eye(5) ;
        A_full(1:3,1:3) = A(1:3,1:3)*1000 ;  % *1000 converts um back to nm (but why convert to um in the first place?)
        A_full(1:3,5) = A(1:3,4)*1000 ;
        A_full(5,1:3) = A(4,1:3)*1000 ;  % probably not necessary, these are all zero close to zero
        final_affine_transform_from_tile_index(:,:,tile_index) = A_full ;
    end
    fprintf('Done updating per-tile affine transforms based on control point targets.\n')
    
    % Package everything up in a single struct for return
    vecfield = struct() ;
    vecfield.root = vecfield_root ;
    vecfield.path = vecfield_path ;
    vecfield.control = targets_from_tile_index;
    vecfield.xlim_cntrl = cpg_i0_values;
    vecfield.ylim_cntrl = cpg_j0_values;
    vecfield.zlim_cntrl = cpg_k0_values_from_tile_index;
    vecfield.afftile = baseline_affine_transform_from_tile_index;
    vecfield.tform = final_affine_transform_from_tile_index;
    vecfield.corrctrlpnttmp = field_corrected_cpg_ij0s;
    vecfield.ctrlpnttmp = cpg_ij1s-1;
    vecfield.bbox = bbox;
    vecfield.origin = origin;
    vecfield.sz = sz;
    vecfield.time = datestr(now);
    vecfield.theselayers = tile_k_from_run_layer_index;
end
