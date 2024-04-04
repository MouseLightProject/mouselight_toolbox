% Specify the input/output folders
sample_date = '2022-02-01'
analysis_tag = 'production-classifier-z-match-count-threshold-50-alt-test' 
do_force_computations = false
do_perform_field_correction = false
do_run_in_debug_mode = false
do_show_visualizations = true

% Define the paths for various things
%script_folder_path = fileparts(mfilename('fullpath')) 

raw_tile_root_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) 
%stage_1_root_folder_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_date) 
%stage_2_root_folder_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', sample_date) 
landmark_root_folder_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', sample_date) 
z_match_root_folder_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output', sample_date) 

sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date) 
analysis_memo_folder_path = fullfile(sample_memo_folder_path, analysis_tag) 
stitching_output_folder_path = fullfile(analysis_memo_folder_path, 'stitching-output')

% Set the options
options = ...
    struct('do_force_computations', do_force_computations, ...
           'do_perform_field_correction', do_perform_field_correction, ...
           'do_run_in_debug_mode', do_run_in_debug_mode, ...
           'do_show_visualizations', do_show_visualizations) ;

% Call the function that does the real work
stitch_and_compute_match_errors(raw_tile_root_folder_path, ...
                                sample_memo_folder_path, ...
                                analysis_memo_folder_path, ...
                                landmark_root_folder_path, ...
                                z_match_root_folder_path, ...
                                stitching_output_folder_path, ...
                                options)
                            