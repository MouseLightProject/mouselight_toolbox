function write_tile_metadata(tile_metadata_file_path, shift, is_x_flipped, is_y_flipped)
    fid = fopen(tile_metadata_file_path, 'wt') ;
    if fid<0 ,
        error('Unable to open file %s for writing', tile_metadata_file_path) ;
    end
    luc_besson = onCleanup(@()(fclose(fid))) ;
    fprintf(fid, 'shift: %d\n', shift) ;
    fprintf(fid, 'is_x_flipped: %s\n', fif(is_x_flipped, 'true', 'false')) ;
    fprintf(fid, 'is_y_flipped: %s\n', fif(is_y_flipped, 'true', 'false')) ;
end
