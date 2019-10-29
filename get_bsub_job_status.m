function result = get_bsub_job_status(job_ids)
    job_count = length(job_ids) ;
    result = zeros(size(job_ids)) ;
    for job_index = 1 : job_count ,
        job_id = job_ids(job_index) ;
        this_status = get_single_bsub_job_status(job_id) ;
        result(job_index) = this_status ;
    end
end
