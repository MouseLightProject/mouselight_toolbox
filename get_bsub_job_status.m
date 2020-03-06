function result = get_bsub_job_status(job_ids)
    % Possible results are {-1,0,+1} for each job_id.
    %   -1 means errored out
    %    0 mean running or pending
    %   +1 means completed successfully
    
    job_count = length(job_ids) ;
    result = zeros(size(job_ids)) ;
    for job_index = 1 : job_count ,
        job_id = job_ids(job_index) ;
        this_status = get_single_bsub_job_status(job_id) ;
        result(job_index) = this_status ;
    end
end
