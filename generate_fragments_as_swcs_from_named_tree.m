function generate_fragments_as_swcs_from_named_tree(fragment_output_folder_path, ...
                                                    named_tree, ...
                                                    minimum_centerpoint_count_per_fragment, ...
                                                    bounding_box_low_corner_xyz, ...
                                                    bounding_box_high_corner_xyz)

    % Break the tree into fragments, in main memory
    fragments_as_named_trees = ...
        named_forest_of_fragments_from_named_tree(named_tree, ...
                                                  minimum_centerpoint_count_per_fragment, ...
                                                  bounding_box_low_corner_xyz, ...
                                                  bounding_box_high_corner_xyz) ;
                                                
    % Write each fragment to disk as a .swc file
    fragment_count = length(fragments_as_named_trees) ;    
    parfor fragment_index = 1:fragment_count ,
        fragment_as_named_tree = fragments_as_named_trees(fragment_index) ;
        
        % .swc file name
        fragment_name = fragment_as_named_tree.name ;
        fragment_swc_file_name = sprintf('%s.swc', fragment_name) ;
        fragment_swc_file_path = fullfile(fragment_output_folder_path, fragment_swc_file_name);

        % If the output file already exists, skip it
        if exist(fragment_swc_file_path, 'file') ,
            continue ;
        end       
        
        % Save the fragment to a .swc file
        save_named_tree(fragment_swc_file_path, fragment_as_named_tree) ;        
    end
end
