function job_id = bsub(do_actually_submit, options, function_handle, varargin)
    % Wrapper for LSF bsub command.  Returns job id as a double.
    % Throws error if anything goes wrong.
    if do_actually_submit ,
        function_name = func2str(function_handle) ;
        arg_string = generate_arg_string(varargin{:}) ;
        matlab_command = sprintf('modpath; %s(%s);', function_name, arg_string) ;
        bash_command = sprintf('matlab -batch "%s"', matlab_command) ;
        bsub_command = ...
            sprintf('bsub -eo /dev/null -oo /dev/null %s %s', options, bash_command) ;
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
    elseif isstruct(thing) && isscalar(thing) ,
        result = 'struct(' ;
        field_names = fieldnames(thing) ;
        field_count = length(field_names) ;
        for i = 1 : field_count ,
            field_name = field_names{i} ;
            field_value = thing.(field_name) ;
            field_value_as_string = tostring(field_value) ;
            subresult = sprintf('''%s'', {%s}', field_name, field_value_as_string) ;
            result = horzcat(result, subresult) ; %#ok<AGROW>
            if i<field_count ,
                result = horzcat(result, ', ') ; %#ok<AGROW>
            end            
        end
        result = horzcat(result, ')') ;
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
