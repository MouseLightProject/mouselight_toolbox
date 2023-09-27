function result = are_files_same_size_and_md5sum(file_name_1, file_name_2)
    file_size_1 = get_file_size(file_name_1) ;
    file_size_2 = get_file_size(file_name_2) ;
    if file_size_1 ~= file_size_2 ,
        result = false ;
        return
    end
    result = are_md5s_the_same(file_name_1, file_name_2) ;
end
