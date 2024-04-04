sample_date = '2022-02-01'
fluorescence_root_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_date) 
sample_memo_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s', sample_date) 
do_use_bqueue = true 
do_actually_submit = true 
do_run_in_debug_mode = false

fix_line_shift_in_place_for_sample(fluorescence_root_folder_path, sample_memo_folder_path, do_use_bqueue, do_actually_submit, do_run_in_debug_mode) ;
