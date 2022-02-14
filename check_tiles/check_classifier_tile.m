function [problematic_stage_output_tile_relative_paths, problematic_stage_output_tile_messages] = ...
    check_classifier_tile(stage_output_tile_folder_path, ...
                          putative_stage_output_tile_relative_path, ...
                          nominal_raw_tif_file_size, ...
                          nominal_tile_shape_yxz, ...
                          problematic_stage_output_tile_relative_paths, ...
                          problematic_stage_output_tile_messages)  %#ok<INUSL>
                      
    putative_stage_output_tile_absolute_path = fullfile(stage_output_tile_folder_path, ...
                                                        putative_stage_output_tile_relative_path) ;
    nominal_tile_shape_xyz = nominal_tile_shape_yxz([2 1 3]) ;                      
    try
        info = h5info(putative_stage_output_tile_absolute_path, '/') ;
        did_get_info = true ;                        
    catch err 
        if isequal(err.identifier, 'MATLAB:imagesci:h5info:fileOpenErr') ,
            problematic_stage_output_tile_relative_paths = ...
                horzcat(problematic_stage_output_tile_relative_paths, putative_stage_output_tile_relative_path) ;
            problematic_stage_output_tile_messages = ...
                horzcat(problematic_stage_output_tile_messages, ...
                        sprintf('Trying to read %s caused the error %s', ...
                                putative_stage_output_tile_relative_path, err.message)) ;
            did_get_info = false ;
        else
            rethrow(err) ;
        end
    end
    if did_get_info ,
        thing_names = {info.Datasets.Name} ;
        % should be only one
        if isempty(thing_names) ,
            problematic_stage_output_tile_relative_paths = ...
                horzcat(problematic_stage_output_tile_relative_paths, ...
                        putative_stage_output_tile_relative_path) ;
            problematic_stage_output_tile_messages = ...
                horzcat(problematic_stage_output_tile_messages, ...
                        sprintf('%s contains zero datasets', putative_stage_output_tile_relative_path)) ;
        else
            thing_name = thing_names{1} ;
            %dataset = h5read(putative_stage_output_tile_absolute_path, sprintf('/%s', thing_name)) ;
            dataset_info = h5info(putative_stage_output_tile_absolute_path, sprintf('/%s', thing_name)) ;
            raw_shape_xyz = dataset_info.Dataspace.Size ;
            % Sometimes the shape has a leading singleton dimension, so trim that off
            if length(raw_shape_xyz) == 4 && raw_shape_xyz(1)==1 ,
                shape_xyz = raw_shape_xyz(end-2:end) ;
            else
                shape_xyz = raw_shape_xyz ;
            end
            dtype = dataset_info.Datatype.Type ;
            if ~isequal(shape_xyz, nominal_tile_shape_xyz) ,
                problematic_stage_output_tile_relative_paths = ...
                    horzcat(problematic_stage_output_tile_relative_paths, ...
                            putative_stage_output_tile_relative_path) ;
                problematic_stage_output_tile_messages = ...
                    horzcat(problematic_stage_output_tile_messages, ...
                            sprintf('%s is the wrong shape: shape (xyz) is %s', ...
                                    putative_stage_output_tile_relative_path, ...
                                    num2str(shape_xyz))) ;
            elseif ~isequal(dtype, 'H5T_STD_U16LE') ,
                problematic_stage_output_tile_relative_paths = ...
                    horzcat(problematic_stage_output_tile_relative_paths, ...
                            putative_stage_output_tile_relative_path) ;
                problematic_stage_output_tile_messages = ...
                    horzcat(problematic_stage_output_tile_messages, ...
                            sprintf('%s is the wrong data type, type is %s', putative_stage_output_tile_relative_path, dtype)) ;
            end
        end
    end
end
