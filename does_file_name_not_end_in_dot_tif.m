function result = does_file_name_not_end_in_dot_tif(varargin)
    % The args may be a single arg with the file path, or several args that, when
    % fullfile()'d together, become a file path.  In any case, all we care about
    % is that the last one does not end in '.tif'
    file_name = varargin{nargin} ;
    result = ~(does_match_regexp(file_name, '\.tif$')) ;
end
