function result = read_metadata_file(sample_metadata_file_name)    
    % Read the channel semantics file and extract the relevant information
    sample_metadata_lines = read_file_into_cellstring(sample_metadata_file_name) ;
    result = struct() ;    
    for line_index = 1: length(sample_metadata_lines) ,        
        line = strtrim(sample_metadata_lines{line_index}) ;
        if isempty(line) ,
            % skip empty lines
            continue
        end
        tokens = strtrim(strsplit(line, ':')) ;
        if length(tokens) ~= 2 ,
            error('Unable to parse line in channel semantics file: "%s"', line) ;
        end
        field_name = tokens{1} ;
        field_value_as_string = tokens{2} ;
        if strcmp(field_name, 'neuron_channel_index') ,
            field_value = str2double(field_value_as_string) ;
            if field_value ~= 0 && field_value ~= 1 ,
                error('Bad %s field in metadata file: "%s"', field_name, field_value_as_string) ;
            end
            result.neuron_channel_index = field_value ;
        elseif strcmp(field_name, 'background_channel_index') ,
            field_value = str2double(field_value_as_string) ;
            if field_value ~= 0 && field_value ~= 1 ,
                error('Bad %s field in metadata file: "%s"', field_name, field_value_as_string) ;
            end
            result.background_channel_index = field_value ;
        elseif strcmp(field_name, 'is_x_flipped') ,
            try
                field_value = str2logical(field_value_as_string) ;
            catch me
                if strcmp(me.identifier, 'str2logical:bad_input') ,
                    error('Bad value for %s field in metadata file: "%s"', field_name, field_value_as_string) ;
                else
                    rethrow(me) ;
                end
            end                    
            result.is_x_flipped = field_value ;
        elseif strcmp(field_name, 'is_y_flipped') ,
            try
                field_value = str2logical(field_value_as_string) ;
            catch me
                if strcmp(me.identifier, 'str2logical:bad_input') ,
                    error('Bad value for %s field in metadata file: "%s"', field_name, field_value_as_string) ;
                else
                    rethrow(me) ;
                end
            end                    
            result.is_y_flipped = field_value ;
        elseif strcmp(field_name, 'shift') ,
            field_value = str2double(field_value_as_string) ;
            if field_value ~= round(field_value) ,
                error('Bad %s field in metadata file: "%s"', field_name, field_value_as_string) ;
            end
            result.shift = field_value ;
        else
            % Just retain the value as a string
            result.(field_name) = field_value_as_string ;
        end            
    end
end
