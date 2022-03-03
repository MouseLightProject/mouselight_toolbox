function result = post_line_fix_sample_metadata_from_original_sample_metadata(original_sample_metadata)
    % Drop the is_*_flipped fields, because now those are specified for each tile.
    result = rmfield(original_sample_metadata, {'is_x_flipped', 'is_y_flipped'}) ;
end
