% Set parameters
do_line_fix = true ;
ilastik_project_file_name = '' ;
do_force_computation = false ;
do_use_bsub = true ;
do_actually_submit = true ;
do_run_in_debug_mode = true ;

% Build an index of the paths to raw tiles
sample_date = '2022-02-01' ;
script_folder_path = fileparts(mfilename('fullpath')) ;
raw_root_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) ;
sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date) ;
line_fix_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_1_line_fix_output', sample_date) ;
p_map_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_2_classifier_output', sample_date) ;
landmark_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_3_descriptor_output', sample_date) ;
z_point_match_root_path = sprintf('/nrs/mouselight/pipeline_output/%s/stage_4_point_match_output', sample_date) ;


% Run the generic script
run_all_tiles_through_1234_stages
