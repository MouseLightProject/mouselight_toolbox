function result = does_file_name_not_end_in_dot_tif(file_name)
    result = ~(does_match_regexp(file_name, '.tif$')) ;
end
