function verify_single_mj2_file_after_freezing(tif_file_path, tif_root_folder_name, mj2_root_folder_name)
    % Checks that the mj2 is similar to the .tif, and outputs a .similar-mj2-exists file in the
    % tif folder if they are similar.  If unable to verify, writes nothing.
    relative_file_path_of_tif = relpath(tif_file_path, tif_root_folder_name) ;
    relative_file_path_of_mj2 = replace_extension(relative_file_path_of_tif, '.mj2') ;
    mj2_file_path = fullfile(mj2_root_folder_name, relative_file_path_of_mj2) ;
    check_file_path = horzcat(mj2_file_path, '.is-similar-to-tif') ;    
    not_check_file_path = horzcat(mj2_file_path, '.is-not-similar-to-tif') ;    
    if exist(check_file_path, 'file') ,
        return
    end
    if exist(mj2_file_path, 'file') ,
        try                        
            mj2_stack = read_16bit_grayscale_mj2(mj2_file_path) ;
        catch err %#ok<NASGU>
            return
        end
        tif_stack = read_16bit_grayscale_tif(tif_file_path) ;
        fpe_value = fraction_variance_explained(mj2_stack, tif_stack) ;
        if fpe_value > 0.75 ,
            write_string_to_file(check_file_path, sprintf('%.10f\n', fpe_value)) ;
        else
            write_string_to_file(not_check_file_path, sprintf('%.10f\n', fpe_value)) ;            
        end        
%         if is_mj2_similar_to_tif(mj2_stack, tif_stack) ,
%             touch(check_file_path) ;
%         else
%             %nop() ;
%         end
    else
        %nop() ;
    end
end
