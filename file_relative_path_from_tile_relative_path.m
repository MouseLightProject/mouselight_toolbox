function result = file_relative_path_from_tile_relative_path(varargin) 
    % E.g. '2020-12-01/01/01916' -> '2020-12-01/01/01916/01916-ngc.0.tif'
    result = file_path_from_tile_path(varargin{:}) ;
end
