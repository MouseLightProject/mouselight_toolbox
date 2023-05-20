function result = find_and_list(root_folder_path, is_file_a_keeper_predicate)
    seed = cell(1,0) ;
    result = file_accumulate_map_filter(root_folder_path, seed, @accumulator, @mapper, is_file_a_keeper_predicate) ;
end

function result = accumulator(result_so_far, file_value)
    result = horzcat(result_so_far, {file_value}) ;
end

function result = mapper(root_folder_path, base_folder_relative_path, file_name, depth)  %#ok<INUSD> 
    result = fullfile(root_folder_path, base_folder_relative_path, file_name) ;
end


% 
% function list = ...
%         find_and_list_helper(base_folder_path, ...
%                              is_file_a_keeper_predicate, ...
%                              initial_list, ...
%                              varargin)
%     list = initial_list ;
%     [file_names, is_file_a_folder] = simple_dir(base_folder_path) ;
%     file_count = length(file_names) ;
%     for i = 1 : file_count ,
%         file_name = file_names{i} ;
%         is_this_file_a_folder = is_file_a_folder(i) ;
%         file_path = fullfile(base_folder_path, file_name) ;
%         if is_this_file_a_folder ,
%             % if a folder, recurse
%             list = ...
%                 find_and_list_helper(file_path, ...
%                                      is_file_a_keeper_predicate, ...
%                                      list, ...
%                                      varargin{:}) ;
%         else
%             if feval(is_file_a_keeper_predicate, file_path, varargin{:}) ,
%                 list = horzcat(list, {file_path}) ;  %#ok<AGROW>
%             end
%         end
%     end    
% end
