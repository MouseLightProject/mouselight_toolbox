sample_date = '2022-02-01' ;
broken_tile_paths = { ...
    '2022-02-05/02/02572', ...
    '2022-02-05/02/02638', ...
    '2022-02-05/02/02646', ...
    '2022-02-05/02/02650', ...
    '2022-02-05/02/02664', ...
    '2022-02-05/02/02668', ...
    '2022-02-05/02/02672', ...
    '2022-02-05/02/02686', ...
    '2022-02-05/02/02690', ...
    '2022-02-05/02/02698', ...
    '2022-02-05/02/02699', ...
    '2022-02-05/02/02704', ...
    '2022-02-05/02/02713', ...
    '2022-02-05/02/02730', ...
    '2022-02-05/02/02734' } ;

pipeline_output_folder_path_template_from_stage_index = { ...
    '/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', ...
    '/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', ...
    '/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', ...
    '/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output'} ;
pipeline_output_folder_from_stage_index = ...
    cellfun(@(template)(sprintf(template, sample_date)), pipeline_output_folder_path_template_from_stage_index, 'UniformOutput', false) ;

stage_count = length(pipeline_output_folder_from_stage_index) ;
for stage_index = 1 : stage_count ,
    root_path = pipeline_output_folder_from_stage_index{stage_index} 
    cellfun(@(tile_path)(system_from_list_with_error_handling({'rm', '-rf', fullfile(root_path, tile_path)})), broken_tile_paths, 'UniformOutput', false) ;
end