function result = find_and_count(root_folder_path, is_file_a_keeper_predicate, folder_filter_function)
    seed = 0 ;  % for counting, start with a count of zero

    function result = filter(root_folder_path, base_folder_relative_path, file_name, depth, is_this_file_a_folder)  %#ok<INUSD>
        result = feval(is_file_a_keeper_predicate, root_folder_path, base_folder_relative_path, file_name) ;
    end

    result = file_accumulate_map_filter(root_folder_path, seed, @accumulator, @mapper, @filter, folder_filter_function) ;
end

function result = accumulator(result_so_far, file_value)
    % For counting, just add the file_value to the ongoing count
    result = result_so_far + file_value ;
end

function result = mapper(root_folder_path, base_folder_relative_path, file_name, depth)  %#ok<INUSD> 
    % For counting, just want to return one for each file that gets past the
    % filter
    result = 1 ;
end


% function result = find_and_count(base_folder_path, is_file_a_keeper_predicate, varargin)
%     [folder_predicate_function] = ...
%         parse_keyword_args(...
%         varargin, ...
%         'folder_predicate_function', @(folder_path, depth)(true)) ;
%     
%     result = ...
%         find_and_count_helper(base_folder_path, ...
%                               is_file_a_keeper_predicate, ...
%                               folder_predicate_function, ...
%                               0, ...
%                               0) ;
% end
% 
% 
% 
% function result = ...
%         find_and_count_helper(base_folder_path, ...
%                               is_file_a_keeper_predicate, ...
%                               folder_predicate_function, ...
%                               depth, ...
%                               incoming_count)
%     count_so_far = incoming_count ;
%     [file_names, is_file_a_folder] = simple_dir(base_folder_path) ;
%     file_count = length(file_names) ;
%     for i = 1 : file_count ,
%         file_name = file_names{i} ;
%         is_this_file_a_folder = is_file_a_folder(i) ;
%         file_path = fullfile(base_folder_path, file_name) ;
%         if is_this_file_a_folder ,
%             % if a folder satisfying predicate function, recurse
%             if feval(folder_predicate_function, file_path, depth) ,
%                 count_so_far = ...
%                     find_and_count_helper(...
%                         file_path, ...
%                         is_file_a_keeper_predicate, ...
%                         folder_predicate_function, ...
%                         depth+1, ...
%                         count_so_far) ;
%             end
%         else
%             if feval(is_file_a_keeper_predicate, file_path) ,
%                 count_so_far = count_so_far + 1 ;
%             end
%         end
%     end    
%     result = count_so_far ;
% end
