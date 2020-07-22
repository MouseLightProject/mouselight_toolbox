do_actually_submit = true ;
max_running_job_count = 10 ;
bqueue = bqueue_type(do_actually_submit, max_running_job_count) ;

bsub_options = '-n1 -P mouselight -W 59 -J test-bqueue' ;

job_count = 20 ;
for job_index = 1 : job_count ,
    bqueue.enqueue(bsub_options, @pause, 20) ;
end

maximum_wait_time = 100 ;
do_show_progress_bar = true ;
job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) 
