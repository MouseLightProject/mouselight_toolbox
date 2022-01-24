function result = correctTiles(ijk1_from_point_index, stack_shape_ijk)
    % Flip the given voxel coordinates in x and y.
    % Note that stack_shape_ijk must be in voxels, and in xyz order
    % Each row of ijk1_from_point_index must give the integer coordinates of a voxel in xyz
    % order, using one-based indexing.
    result = ijk1_from_point_index ;
    result(:,1:2) = stack_shape_ijk(1:2) - ijk1_from_point_index(:, 1:2) + 1 ;
end
