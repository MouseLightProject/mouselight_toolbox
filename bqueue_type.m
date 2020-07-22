classdef bqueue_type < handle
    properties (SetAccess = private)
        do_actually_submit = true
        options = cell(1,0)
        function_handle = cell(1,0)
        other_arguments = cell(1,0)
        %job_status = nan(1,0) ;
        maximum_running_job_count = inf        
        job_ids = zeros(1,0)
        has_job_been_submitted = false(1,0)
    end
    
    methods
        function self = bqueue_type(do_actually_submit, maximum_running_job_count)
            self.do_actually_submit = do_actually_submit ;
            self.maximum_running_job_count = maximum_running_job_count ;
        end
        
        function result = queue_length(self)
            result = length(self.has_job_been_submitted) ;
        end
        
        function enqueue(self, options, function_handle, varargin)
            job_index = self.queue_length() + 1 ;
            self.options{1,job_index} = options ;
            self.function_handle{1,job_index} = function_handle ;
            self.other_arguments(1,job_index) = {varargin(:)} ;            
            %self.job_status(1,job_index) = nan ;  % nan means unsubmitted
            self.job_ids(1,job_index) = nan ;            
            self.has_job_been_submitted(1,job_index) = false ;            
        end
        
        function job_statuses = run(self, maximum_wait_time, do_show_progress_bar)
            if ~exist('maximum_wait_time', 'var') || isempty(maximum_wait_time) ,
                maximum_wait_time = inf ;
            end
            if ~exist('do_show_progress_bar', 'var') || isempty(do_show_progress_bar) ,
                do_show_progress_bar = true ;
            end

            have_all_exited = false ;
            is_time_up = false ;
            job_count = self.queue_length() ;
            if do_show_progress_bar ,
                progress_bar = progress_bar_object(job_count) ;
            end
            ticId = tic() ;
            while ~have_all_exited && ~is_time_up ,
                old_job_ids = self.job_ids ;                
                job_statuses = get_bsub_job_status(old_job_ids) ; 
                is_job_in_progress = self.has_job_been_submitted & (job_statuses==0) ;
                carryover_job_ids = old_job_ids(is_job_in_progress) ;
                carryover_job_count = length(carryover_job_ids) ;
                maximum_new_job_count = self.maximum_running_job_count - carryover_job_count ;
                if maximum_new_job_count > 0 ,
                    is_job_submittable = ~self.has_job_been_submitted ;
                    submittable_job_indices = find(is_job_submittable) ;
                    submittable_job_count = sum(is_job_submittable) ;
                    if submittable_job_count > maximum_new_job_count ,
                        job_indices_to_submit = submittable_job_indices(1:maximum_new_job_count) ;
                    else
                        job_indices_to_submit = submittable_job_indices ;
                    end
                    jobs_to_submit_count = length(job_indices_to_submit) ;
                    for i = 1 : jobs_to_submit_count ,
                        job_index = job_indices_to_submit(i) ;
                        this_function_handle = self.function_handle{job_index} ;
                        this_other_arguments = self.other_arguments{job_index} ;
                        this_options = self.options{job_index} ;
                        this_job_id = bsub(self.do_actually_submit, this_options, this_function_handle, this_other_arguments{:}) ;
                        self.job_ids(job_index) = this_job_id ;
                        self.has_job_been_submitted(job_index) = true ;
                        is_job_in_progress(job_index) = true ;
                    end
                end                                
                has_job_exited = self.has_job_been_submitted & ~is_job_in_progress ;
                exited_job_count = sum(has_job_exited) ;
                if do_show_progress_bar ,
                    progress_bar.update(exited_job_count) ;
                end
                have_all_exited = (exited_job_count==job_count) ;        
                if ~have_all_exited ,  
                    if self.do_actually_submit ,
                        pause(10) ;
                    end
                    is_time_up = (toc(ticId) > maximum_wait_time) ;
                end
            end
            if do_show_progress_bar ,
                progress_bar.finish_up() ;
            end
        end
    end
end
