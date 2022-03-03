function write_post_line_fix_sample_metadata(tile_root_path, post_line_fix_sample_metadata)
    post_line_fix_sample_metadata_file_name = 'post-line-fix-sample-metadata.txt' ;
    post_line_fix_sample_metadata_file_path = fullfile(tile_root_path, post_line_fix_sample_metadata_file_name) ;
    write_metadata_file(post_line_fix_sample_metadata_file_path, post_line_fix_sample_metadata) ;
end

