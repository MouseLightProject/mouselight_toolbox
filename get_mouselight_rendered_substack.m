function substack = get_mouselight_rendered_substack(rendered_folder_name, channel_index, substack_origin_ijk1, substack_shape_ijk)
    % stack_origin should be in one-based voxel coords
    % the returned stack will include the voxel indicated by stack_origin
    parameter_file_name = fullfile(rendered_folder_name, 'calculated_parameters.jl') ;
    parameters = read_renderer_calculated_parameters_file(parameter_file_name) ;
    level_step_count = parameters.level_step_count ;
    chunk_shape_ijk = parameters.leaf_shape ;  % xyz order
    
    %substack_far_corner_ijk1 = substack_origin_ijk1 + substack_shape_ijk - 1 ;  % coords of the voxel in the substack with the largest coords    
    [substack_chunk_origin_ijk1, substack_shape_in_chunks_ijk] = ...
        chunk_bounding_box_from_bounding_box(substack_origin_ijk1, substack_shape_ijk, chunk_shape_ijk) ;
    
    chunk_aligned_substack_shape_ijk = substack_shape_in_chunks_ijk .* chunk_shape_ijk ;
    chunk_aligned_substack = zeros(chunk_aligned_substack_shape_ijk([2 1 3]), 'uint16') ;
    for i1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(1) ,
        for j1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(2) ,
            for k1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(3) ,
                ijk1_chunk_within_substack = [i1_chunk_within_substack j1_chunk_within_substack k1_chunk_within_substack] ;
                ijk1_chunk_within_stack = substack_chunk_origin_ijk1 + ijk1_chunk_within_substack - 1 ;
                octree_path = octree_paths_from_chunk_ijk1s(ijk1_chunk_within_stack, level_step_count) ;
                chunk = load_mouselight_rendered_chunk(rendered_folder_name, octree_path, channel_index) ;
                ijk1_chunk_origin_within_substack = chunk_shape_ijk .* (ijk1_chunk_within_substack-1) + 1 ;
                ijk1_chunk_far_corner_within_substack = ijk1_chunk_origin_within_substack + chunk_shape_ijk - 1 ;
                chunk_aligned_substack(ijk1_chunk_origin_within_substack(2):ijk1_chunk_far_corner_within_substack(2) , ...
                                       ijk1_chunk_origin_within_substack(1):ijk1_chunk_far_corner_within_substack(1) , ...
                                       ijk1_chunk_origin_within_substack(3):ijk1_chunk_far_corner_within_substack(3)) = chunk ;
            end
        end
    end
    
    chunk_aligned_substack_origin_ijk1 = (substack_chunk_origin_ijk1-1) .* chunk_shape_ijk + 1 ;
    substack_origin_within_chunk_aligned_substack_ijk1 = substack_origin_ijk1 - chunk_aligned_substack_origin_ijk1 + 1 ;
    substack_far_corner_within_chunk_aligned_substack_ijk1 = substack_origin_within_chunk_aligned_substack_ijk1 + substack_shape_ijk - 1 ;
    substack = chunk_aligned_substack(substack_origin_within_chunk_aligned_substack_ijk1(2):substack_far_corner_within_chunk_aligned_substack_ijk1(2), ...
                                      substack_origin_within_chunk_aligned_substack_ijk1(1):substack_far_corner_within_chunk_aligned_substack_ijk1(1), ...
                                      substack_origin_within_chunk_aligned_substack_ijk1(3):substack_far_corner_within_chunk_aligned_substack_ijk1(3)) ;
end
