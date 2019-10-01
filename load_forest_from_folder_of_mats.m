function forest = load_forest_from_folder_of_mats(input_folder_path)
    full_tree_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*.mat')) ;
    full_tress_to_process_count = length(full_tree_file_names) ;
    color_map = distinct_hues_simple() ;
    color_map_count = size(color_map,1) ;
    fprintf('Starting the big parfor loop, going to load %d full trees...\n', full_tress_to_process_count) ;
    forest = empty_named_tree_struct(full_tress_to_process_count, 1) ;    
    parfor_progress(full_tress_to_process_count) ;
    parfor full_tree_index = 1 : full_tress_to_process_count ,
        full_tree_file_name = full_tree_file_names{full_tree_index} ;
        full_tree_mat_file_path = fullfile(input_folder_path, full_tree_file_name) ;
        full_tree_name = base_name_from_file_name(full_tree_mat_file_path) ;
        [~, tree_as_struct] = load_full_tree_from_mat(full_tree_mat_file_path) ;
        named_tree_struct = named_tree_from_tree_as_dA_struct(tree_as_struct) ;
%         xyz = tree_as_swc_array(:,3:5) ;
%         parent = tree_as_swc_array(:,7) ;
%         tag_code = tree_as_swc_array(:,2) ;
%         r = tree_as_swc_array(:,6) ;
        color_index = mod(full_tree_index-1, color_map_count) + 1 ;
        color = color_map(color_index, :) ;  %#ok<PFBNS>
%         named_tree_struct = struct('name', full_tree_name, ...
%                                    'color', color, ...
%                                    'xyz', xyz, ...
%                                    'r', r, ...
%                                    'parent', parent, ...
%                                    'tag_code', tag_code) ;
        named_tree_struct.name = full_tree_name ;
        named_tree_struct.color = color ;
        forest(full_tree_index) = named_tree_struct ;        
        % Update the progress bar
        parfor_progress() ;
    end
    parfor_progress(0) ;
end
