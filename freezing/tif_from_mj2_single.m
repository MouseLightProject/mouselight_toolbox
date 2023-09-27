function tif_from_mj2_single(tif_output_file_name, mj2_input_file_name, do_verify)
    % Converts a single .mj2 file at input_file_name to a multi-image .tif
    % at output_file_name.  Will overwrite pre-existing file at
    % output_file_name, if present.
    
    if ~exist('do_verify', 'var') || isempty(do_verify) ,
        do_verify = false ;
    end
    
    input_file = VideoReader(mj2_input_file_name) ;
    frame_index = 0 ;
    while input_file.hasFrame() ,
        frame_index = frame_index + 1 ; 
        frame = input_file.readFrame() ;
        if frame_index == 1 ,
            imwrite(frame, tif_output_file_name, 'tif', 'WriteMode', 'overwrite',  'Compression', 'deflate') ;
        else
            imwrite(frame, tif_output_file_name, 'tif', 'WriteMode', 'append',  'Compression', 'deflate') ;            
        end        
    end    
    
    if do_verify ,
        if ~is_mj2_same_as_tif(mj2_input_file_name, tif_output_file_name) ,
            error('%s is not the same as %s\n', tif_output_file_name, mj2_input_file_name) ;
        end
    end
end
