function find_and_batch(base_folder_path, is_batch_input_predicate, batch_function, do_submit, maximum_running_slot_count, slots_per_job, bsub_options, varargin)
    %bqueue = bqueue_type(do_submit, bsub_options, slots_per_job, maximum_running_slot_count) ;
    bqueue = bqueue_type(do_submit, maximum_running_slot_count) ;
    find_and_batch_helper_bang(bqueue, ...
                               slots_per_job, ...
                               bsub_options, ...
                               base_folder_path, ...
                               is_batch_input_predicate, ...
                               batch_function, ...
                               varargin{:}) ;
    fprintf('Waiting for %d find_and_batch %s() jobs to finish...\n', bqueue.queue_length(), func2str(batch_function)) ;
    job_statuses = bqueue.run() ;
    if all(job_statuses==1) ,
        fprintf('All %d %s() batch jobs completed without errors.\n', bqueue.queue_length(), func2str(batch_function)) ;
    else
        fprintf('All %d %s() batch jobs exited, but some had errors.\n', bqueue.queue_length(), func2str(batch_function)) ;
        had_error = (job_statuses==-1) ;
        job_ids = bqueue.job_ids ;
        bad_job_ids = job_ids(had_error) ;
        fprintf('Job ids with errors: %s\n', mat2str(bad_job_ids)) ;
    end
end



function find_and_batch_helper_bang(bqueue, ...
                                    slots_per_job, ...
                                    bsub_options, ...
                                    base_folder_path, ...
                                    is_batch_input_predicate, ...
                                    batch_function, ...
                                    varargin)
    [file_names, is_file_a_folder] = simple_dir(base_folder_path) ;
    file_count = length(file_names) ;
    for i = 1 : file_count ,
        file_name = file_names{i} ;
        is_this_file_a_folder = is_file_a_folder(i) ;
        file_path = fullfile(base_folder_path, file_name) ;
        if is_this_file_a_folder ,
            % if a folder, recurse
            find_and_batch_helper_bang(bqueue, ...
                                       slots_per_job, ...
                                       bsub_options, ...
                                       file_path, ...
                                       is_batch_input_predicate, ...
                                       batch_function, ...
                                       varargin{:}) ;
        else
            if feval(is_batch_input_predicate, file_path, varargin{:}) ,
                bqueue.enqueue(slots_per_job, ...
                               [], ...
                               bsub_options, ...
                               batch_function, ...
                               file_path, ...
                               varargin{:}) ;
            end
        end
    end    
end
