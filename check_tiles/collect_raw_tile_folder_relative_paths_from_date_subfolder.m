function result = collect_raw_tile_folder_relative_paths_from_date_subfolder(raw_tile_folder_path, date_folder_name)
    date_folder_path = fullfile(raw_tile_folder_path, date_folder_name) ;
    initial_raw_tile_folder_relative_paths = cell(1,0) ;  % these will be relative to raw_tile_folder_path    
    raw_tile_folder_relative_paths = dirwalk(date_folder_path, @dirwalk_callback2, initial_raw_tile_folder_relative_paths) ;    
    % Have to append the date_folder_name to each of the raw_tile_file_relative_paths
    result = cellfun(@(raw_tile_folder_relative_path)(fullfile(date_folder_name, raw_tile_folder_relative_path)), ...
                     raw_tile_folder_relative_paths, ...
                     'UniformOutput', false) ;
end



function raw_tile_folder_relative_paths = ...
        dirwalk_callback(root_folder_absolute_path, ...
                         current_folder_relative_path, ...
                         folder_names, ...
                         file_names, ...
                         initial_raw_tile_folder_relative_paths) %#ok<INUSL>
    % If the current folder has no subfolders, add it to the growing list
    if isempty(folder_names) ,
        raw_tile_folder_relative_paths = ...
            horzcat(initial_raw_tile_folder_relative_paths, current_folder_relative_path) ;
    else
        raw_tile_folder_relative_paths = initial_raw_tile_folder_relative_paths ;
    end        
end



function raw_tile_folder_relative_paths = dirwalk_callback2(root_folder_absolute_path, ...
                                                            current_folder_relative_path, ...
                                                            folder_names, ...
                                                            file_names, ...
                                                            initial_raw_tile_folder_relative_paths)  %#ok<INUSL>
    raw_tile_folder_relative_paths = initial_raw_tile_folder_relative_paths ;
    for i = 1 : length(file_names) ,
        file_name = file_names{i} ;
        if ~isempty(regexp(file_name, '-ngc\..\.tif$', 'once')) ,
            raw_tile_folder_relative_paths = ...
                horzcat(raw_tile_folder_relative_paths, current_folder_relative_path) ;  %#ok<AGROW>
            break
        end
    end        
end
