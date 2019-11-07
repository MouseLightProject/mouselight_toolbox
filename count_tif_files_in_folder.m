function result = count_tif_files_in_folder(folder_path)
    folder_absolute_path = absolute_filename(folder_path) ;
    [status, result] = system(sprintf('find %s -name "*.tif" -print | wc -l', folder_absolute_path)) ;
    if status~= 0 ,
        error('Unable to count number of .tif files in %s\n', folder_absolute_path) ;
    end
    result = str2double(result) ;
end
