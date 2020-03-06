classdef bqueue_type
    properties (SetAccess = private)
        do_actually_submit = true(1,0) 
        options = cell(1,0)
        function_handle = function_handle.empty(1,0)
        other_arguments = cell(1,0)
        job_status = nan(1,0) ;
        maximum_running_job_count = inf        
        job_ids = zeros(1,0)
    end
    methods
        function self = bqueue_type(maximum_running_job_count)
            self.maximum_running_job_count = maximum_running_job_count ;
        end
        
        function result = queue_length(self)
            result = length(self.do_actually_submit) ;
        end
        
        function enqueue(self, do_actually_submit, options, function_handle, varargin)
            job_index = self.queue_length() + 1 ;
            self.do_actually_submit(1,job_index) = do_actually_submit ;
            self.options{1,job_index} = options ;
            self.function_handle(1,job_index) = function_handle ;
            self.other_arguments(1,job_index) = {varargin(:)} ;            
            self.job_status(1,job_index) = nan ;  % nan means unsubmitted
        end
        
        function run(self)
            old_job_ids = self.job_ids ;
            job_statuses = bwait(old_job_ids, 0, false) ;
            is_job_in_progess = (job_statuses==0) ;
            is_job_exited = ~is_job_in_progress ;
            carryover_job_ids = old_job_ids(is_job_in_progress) ;
            carryover_job_count = length(carryover_job_ids) ;
            maximum_new_job_count = maximum_running_job_count - carryover_job_count ;
            
            
            
        end
        
    end
end

function job_id = bsub(do_actually_submit, options, function_handle, varargin)
    % Wrapper for LSF bsub command.  Returns job id as a double.
    % Throws error if anything goes wrong.
    if do_actually_submit ,
        function_name = func2str(function_handle) ;
        arg_string = generate_arg_string(varargin{:}) ;
        matlab_command = sprintf('modpath; %s(%s);', function_name, arg_string) ;
        bash_command = sprintf('matlab -batch "%s"', matlab_command) ;
        bsub_command = ...
            sprintf('bsub %s -oo /dev/null -eo /dev/null %s', options, bash_command) ;
        [status, raw_stdout] = system(bsub_command) ;
        if status ~= 0 ,
            error('There was a problem submitting the bsub command %s.  The return code was %d', bsub_command, status) ;
        end
        stdout = strtrim(raw_stdout) ;  % There are leading newlines and other nonsense in the raw version
        raw_tokens = strsplit(stdout) ;
        is_token_nonempty = cellfun(@(str)(~isempty(str)), raw_tokens) ;
        tokens = raw_tokens(is_token_nonempty) ;
        if length(tokens)<2 ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output to get job id.  Output was: %s', bsub_command, stdout) ;
        end
        if ~isequal(tokens{1}, 'Job') ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output to get job id.  Output was: %s', bsub_command, stdout) ;
        end
        job_id_token = tokens{2} ;
        if length(job_id_token)<2 ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output to get job id.  Output was: %s', bsub_command, stdout) ;
        end
        if ~isequal(job_id_token(1), '<') || ~isequal(job_id_token(end), '>') ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output to get job id.  Output was: %s', bsub_command, stdout) ;
        end        
        job_id_as_string = job_id_token(2:end-1) ;
        job_id = str2double(job_id_as_string) ;
        if ~isfinite(job_id) ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output to get job id.  Output was: %s', bsub_command, stdout) ;
        end
    else
        % Just call the function normally
        feval(function_handle, varargin{:}) ;
        job_id = -1 ;  % represents a job that was run locally, and is therefore already done
    end
end



function result = tostring(thing)
    % Converts a range of things to strings that will eval to the thing
    if ischar(thing) ,
        result = sprintf('''%s''', thing) ;
    elseif isnumeric(thing) || islogical(thing) ,
        result = mat2str(thing) ;
    else
        error('Don''t know how to convert something of class %s to string', class(thing)) ;
    end
end



function result = generate_arg_string(varargin) 
    arg_count = length(varargin) ;
    result = char(1,0) ;  % fall-through in case of zero args
    for i = 1 : arg_count ,
        this_arg = varargin{i} ;
        this_arg_as_string = tostring(this_arg) ;
        if i == 1 ,
            result = this_arg_as_string ;
        else
            result = horzcat(result, ', ', this_arg_as_string) ;  %#ok<AGROW>
        end
    end
end
