function result = is_a_tif_in_a_folder_with_no_subfolders(tif_file_path, varargin)
    [tif_folder_path,file_name] = fileparts2(tif_file_path) ;
    is_true_so_far = does_file_name_end_in_dot_tif(file_name) ;
    if ~is_true_so_far ,
        result = false ;
        return
    end
    result = ~does_folder_have_subfolders(tif_folder_path) ;
end
