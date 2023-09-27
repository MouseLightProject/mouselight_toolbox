function verify_single_tif_file_after_thawing(input_file_path, input_root_folder_name, output_root_folder_name)
    % Checks that the output .tif is similar to the .mj2, and outputs a
    % .is-similar-to-tif file in the output folder if they are similar.  If able
    % to run verification, but similarity is below threshold, writes a
    % .is-not-similar-to-tif file. If output file is missing or unreadable, writes
    % nothing.
    input_relative_file_path = relpath(input_file_path, input_root_folder_name) ;
    output_relative_file_path = replace_extension(input_relative_file_path, '.tif') ;
    output_file_path = fullfile(output_root_folder_name, output_relative_file_path) ;
    cert_file_path = horzcat(output_file_path, '.is-similar-to-mj2') ;    
    not_check_file_path = horzcat(output_file_path, '.is-not-similar-to-mj2') ;    
    if exist(cert_file_path, 'file') ,
        return
    end
    if exist(output_file_path, 'file') ,
        try                        
            output_stack = read_16bit_grayscale_tif(output_file_path) ;
        catch err %#ok<NASGU>
            return
        end
        input_stack = read_16bit_grayscale_mj2(input_file_path) ;
        fpe_value = fraction_variance_explained(output_stack, input_stack) ;
        if fpe_value > 0.75 ,
            write_string_to_file(cert_file_path, sprintf('%.10f\n', fpe_value)) ;
        else
            write_string_to_file(not_check_file_path, sprintf('%.10f\n', fpe_value)) ;            
        end        
    end
end
