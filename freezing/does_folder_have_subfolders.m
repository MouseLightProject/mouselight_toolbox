function result = does_folder_have_subfolders(folder_name)
    [name_from_thing_index, is_folder_from_thing_index] = simple_dir(folder_name) ;  %#ok<ASGLU> 
    result = any(is_folder_from_thing_index) ;
end
