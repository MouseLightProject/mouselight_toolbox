function result = does_need_preverification_after_freezing(tif_file_path, tif_root_path, mj2_root_path)
    result = does_file_name_end_in_dot_tif(tif_file_path) && ...
             ~does_is_similar_to_tif_check_file_exist(tif_file_path, tif_root_path, mj2_root_path) ;
end
