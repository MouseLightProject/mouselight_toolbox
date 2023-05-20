function result = does_file_name_end_in_dot_mj2(varargin)
    % The args may be a single arg with the file path, or several args that, when
    % fullfile()'d together, become a file path.  In any case, all we care about
    % is that the last one ends in '.mj2'
    file_name = varargin{nargin} ;
    result = does_match_regexp(file_name, '\.mj2$') ;
end
