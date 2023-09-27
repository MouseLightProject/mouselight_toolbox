function result = is_not_the_ktx_folder(varargin)
    % The last arg should be depth, the rest should be path parts
    depth = varargin{nargin} ;

    % We skip the 'ktx' folder at depth zero, if there is one
    if depth > 0 ,
        result = true ;
        return
    end

    % Must be at depth zero if get here
    last_path_part = varargin{nargin-1} ;
    [~,folder_name] = fileparts2(last_path_part) ;
    do_skip = strcmp(folder_name, 'ktx') ;
    result = ~do_skip ;
end
