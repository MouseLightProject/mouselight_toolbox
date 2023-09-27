function result = is_file_below_depth_limit(file_path, root_folder_path, depth_limit, varargin)
    % Files in the root folder are at depth zero, files in subdirs at depth one,
    % etc.  Returns true for files at depth less than or equal to depth_limit.
    relative_file_path = relpath(file_path, root_folder_path) ;
    [relative_folder_path, ~] = fileparts2(relative_file_path) ;
    relative_folder_path_as_object = path_object(relative_folder_path) ;
    relative_folder_path_as_list = relative_folder_path_as_object.list() ;
    depth = length(relative_folder_path_as_list) ;
    result = (depth<=depth_limit) ;
end
