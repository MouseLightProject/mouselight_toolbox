sample_date = '2022-11-17-david' ;
output_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s-frozen-thawed', sample_date) ;
input_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s-frozen', sample_date) ;
do_run_on_cluster = true ;
do_try = true ;  % not used
maximum_running_slot_count = 500 ;
submit_host_name = if_not_a_submit_host('login2.int.janelia.org') ;

thaw_mouselight_folder( ...
    output_folder_path, ...
    input_folder_path, ...
    do_run_on_cluster, ...
    do_try, ...
    maximum_running_slot_count, ...
    submit_host_name) ;

