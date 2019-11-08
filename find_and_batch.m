function find_and_batch(base_folder_path, is_batch_input_predicate, batch_function, do_submit, bsub_options, varargin)
    job_ids = ...
        find_and_batch_helper(base_folder_path, ...
                              is_batch_input_predicate, ...
                              batch_function, ...
                              do_submit, ...
                              bsub_options, ...
                              zeros(1,0), ...
                              varargin{:}) ;
    fprintf('Waiting for %d find_and_batch %s() jobs to finish...\n', length(job_ids), func2str(batch_function)) ;
    job_statuses = bwait(job_ids) ;
    if all(job_statuses==1) ,
        fprintf('All %d %s() batch jobs completed without errors.\n', length(job_ids), func2str(batch_function)) ;
    else
        fprintf('All %d %s() batch jobs exited, but some had errors.\n', length(job_ids), func2str(batch_function)) ;
        had_error = (job_statuses==-1) ;
        bad_job_ids = job_ids(had_error) ;
        fprintf('Job ids with errors: %s\n', mat2str(bad_job_ids)) ;
    end
end



function job_ids = ...
        find_and_batch_helper(base_folder_path, ...
                              is_batch_input_predicate, ...
                              batch_function, ...
                              do_submit, ...
                              bsub_options, ...
                              initial_job_ids, ...
                              varargin)
    job_ids = initial_job_ids ;                                                 
    [file_names, is_file_a_folder] = simple_dir(base_folder_path) ;
    file_count = length(file_names) ;
    for i = 1 : file_count ,
        file_name = file_names{i} ;
        is_this_file_a_folder = is_file_a_folder(i) ;
        file_path = fullfile(base_folder_path, file_name) ;
        if is_this_file_a_folder ,
            % if a folder, recurse
            job_ids = ...
                find_and_batch_helper(file_path, ...
                                      is_batch_input_predicate, ...
                                      batch_function, ...
                                      do_submit, ...
                                      bsub_options, ...
                                      job_ids, ...
                                      varargin{:}) ;
        else
            if feval(is_batch_input_predicate, file_path, varargin{:}) ,
                job_id = ...
                    bsub(do_submit, ...
                         bsub_options, ...
                         batch_function, ...
                         file_path, ...
                         varargin{:}) ;
                job_ids = horzcat(job_ids, job_id) ; %#ok<AGROW>
            end
        end
    end    
end
