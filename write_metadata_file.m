function write_metadata_file(sample_metadata_file_path, sample_metadata)
    % Write the sample metadata stored in a struct into a text file.
    % Only supports a limited set of data types.
    % Currently: scalar logicals, scalar doubles, and char row vectors.
    fid = fopen(sample_metadata_file_path, 'wt') ;
    if fid < 0 ,
        error('Unable to open file %s for writing', sample_metadata_file_path) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    name_from_field_index = fieldnames(sample_metadata) ;
    field_count = length(name_from_field_index) ;
    for field_index = 1 : field_count ,
        field_name = name_from_field_index{field_index} ;
        field_value = sample_metadata.(field_name) ;
        if islogical(field_value) ,
            fprintf(fid, '%s: %s\n', field_name, fif(field_value, 'true', 'false')) ;
        elseif isa(field_value, 'double') ,
            if field_value==round(field_value) ,
                fprintf(fid, '%s: %d\n', field_name, field_value) ;
            else
                fprintf(fid, '%s: %.17g\n', field_name, field_value) ;
            end
        elseif ischar(field_value) ,
            fprintf(fid, '%s: %s\n', field_name, field_value) ;
        else
            error('Don''t know how to print the value for field %s', field_name) ;
        end
    end
end
