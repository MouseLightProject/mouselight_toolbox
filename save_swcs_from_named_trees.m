function save_swcs_from_named_trees(output_folder_path, ...                         
                                    named_trees)
    
    % Create the folder if it doesn't exist
    tree_count = length(named_trees) ;
    if tree_count>0 && ~exist(output_folder_path, 'file') ,
        mkdir(output_folder_path) ;
    end    
    
    % Write each fragment to disk as a .swc file
    pbo = progress_bar_object(tree_count) ;
    parfor tree_index = 1:tree_count ,
        % Create .swc file name
        tree_name = named_trees(tree_index).name ;
        swc_file_name = horzcat(tree_name, '.swc') ;
        swc_file_path = fullfile(output_folder_path, swc_file_name);

        % If the output file already exists, skip it
        if exist(swc_file_path, 'file') ,
            continue ;
        end
        
        % Get the centerpoints for this neuron
        tree = named_trees(tree_index) ;
        save_swc_from_named_tree(swc_file_path, tree) ;
        pbo.update() ;        
    end
    %pbo = progress_bar_object(0) ;
end
