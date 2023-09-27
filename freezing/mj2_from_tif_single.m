function mj2_from_tif_single(mj2_file_path, tif_file_path, compression_ratio)    
    % Read the input file
    tif_stack = read_16bit_grayscale_tif(tif_file_path) ;
    % Write the output file    
    write_16bit_grayscale_mj2(mj2_file_path, tif_stack, compression_ratio) ;    
end
