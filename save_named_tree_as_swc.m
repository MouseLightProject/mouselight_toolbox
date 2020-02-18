function save_named_tree_as_swc(swc_file_name, named_tree)
    swc_array = swc_array_from_named_tree(named_tree) ;
    save_swc(swc_file_name, swc_array, named_tree.name, named_tree.color) ;        
end
