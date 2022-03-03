function result = collect_raw_tile_folder_relative_paths(raw_tile_folder_path)
    entries = simple_dir(raw_tile_folder_path) ;
    is_date = ~cellfun(@isempty, regexp(entries, '^\d\d\d\d-\d\d-\d\d$')) ;
    date_dir_entries = entries(is_date) ;
    raw_tile_file_relative_paths = cell(1,0) ;
    for i = 1 : length(date_dir_entries) ,
        date_dir_entry = date_dir_entries{i} ;
        raw_tile_file_relative_paths_for_date = ...
            collect_raw_tile_folder_relative_paths_from_date_subfolder(raw_tile_folder_path, date_dir_entry) ;
        raw_tile_file_relative_paths = horzcat(raw_tile_file_relative_paths, raw_tile_file_relative_paths_for_date) ;  %#ok<AGROW>
    end    
    result =  natsort(raw_tile_file_relative_paths) ;
end
