function batch_preverify_stack_files_after_freezing(mj2_folder_name, ...
                                                    tif_folder_name, ...
                                                    do_submit, ...
                                                    do_try, ...
                                                    submit_host_name, ...
                                                    maximum_running_slot_count)
    % Makes sure all the big target files are present in the the destination, and
    % are similar to their source files.
    
    slots_per_job = 4 ;
    bsub_options = '-P mouselight -W 59 -J verify-frozen' ;
    find_and_batch(tif_folder_name, ...
                   @does_need_preverification_after_freezing, ...
                   @verify_single_mj2_file_after_freezing, ...
                   'do_submit', do_submit, ...
                   'do_try', do_try, ...
                   'submit_host_name', submit_host_name, ...
                   'maximum_running_slot_count', maximum_running_slot_count, ...
                   'slots_per_job', slots_per_job, ...
                   'bsub_options', bsub_options, ...
                   'predicate_extra_args', {tif_folder_name, mj2_folder_name}, ...
                   'batch_function_extra_args', {tif_folder_name, mj2_folder_name}) ;
end
