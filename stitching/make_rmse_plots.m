function [f1, f2] = make_rmse_plots(rmse_from_tile_index, ...
                                    match_count_from_tile_index, ...
                                    rmse_from_tile_ijk1, ...
                                    label_string, ...
                                    file_label_string, ...
                                    stitching_output_folder_path)
                         

rmse_from_tile_ijk1_montage = montage_from_stack_ijk(rmse_from_tile_ijk1) ;
f1 = figure('color', 'w', 'Units', 'inches', 'Position', [1 1 12 9]) ;
a1 = axes(f1) ;
imagesc(rmse_from_tile_ijk1_montage, [0 100]) ;
colorbar(a1) ;
title(sprintf('%s match RMSE (um)', label_string)) ; 
drawnow() ;
base_name_1 = fullfile(stitching_output_folder_path, sprintf('%s-z-match-rmse-montage', file_label_string)) ;
print_pdf(f1, base_name_1) ;
print_png(f1, base_name_1) ;

% scatter plot of RMSE and matches per pair
f2 = figure('color', 'w', 'Units', 'inches', 'Position', [1 1 12 9]) ;
a2 = axes(f2) ;
plot(a2, match_count_from_tile_index, rmse_from_tile_index, '.') ;
xlabel(a2, sprintf('%s match count per tile pair', label_string)) ;
ylabel(a2, sprintf('%s match RMSE per tile pair', label_string)) ;
drawnow() ;
base_name_2 = fullfile(stitching_output_folder_path, sprintf('%s-z-match-rmse-scatter-plot', file_label_string)) ;
print_pdf(f2, base_name_2) ;
print_png(f2, base_name_2) ;
