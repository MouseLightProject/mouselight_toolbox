function test_verification_condition(freezing_or_thawing, raw_tiles_or_octree, local_or_cluster, stack_or_non_stack, exact_problem)    
    % This function returns normally if all is well, throws an error if not.

    % Deal with the arguments
    if ~strcmp(freezing_or_thawing, 'freezing') && ~strcmp(freezing_or_thawing, 'thawing') ,
        error('freezing_or_thawing must be ''freezing'' or ''thawing''') ;
    end
    if ~strcmp(raw_tiles_or_octree, 'raw-tiles') && ~strcmp(raw_tiles_or_octree, 'octree') ,
        error('raw_tiles_or_octree must be ''raw-tiles'' or ''octree''') ;
    end
    if ~strcmp(local_or_cluster, 'local') && ~strcmp(local_or_cluster, 'cluster') ,
        error('local_or_cluster must be ''local'' or ''cluster''') ;
    end
    if ~strcmp(stack_or_non_stack, 'stack') && ~strcmp(stack_or_non_stack, 'non-stack') ,
        error('stack_or_non_stack must be ''stack'' or ''non-stack''') ;
    end
    if ~any(strcmp(exact_problem, {'deleted', 'zero-length', 'corrupt'})) ,
        error('exact_problem must be one of ''deleted'', ''zero-length'', or ''corrupt''') ;
    end
    
    % Declare what test we're doing
    fprintf('Testing %s %s %s %s %s...\n', ...
            freezing_or_thawing, raw_tiles_or_octree, local_or_cluster, stack_or_non_stack, exact_problem) ;

    % Define all the needed inputs
    path_to_this_folder = fileparts(mfilename('fullpath')) ;
    output_folder_name = sprintf('%s-%s-test-output-folder', raw_tiles_or_octree, freezing_or_thawing) ;
    output_folder_path = fullfile(path_to_this_folder, output_folder_name) ;
    input_folder_name = sprintf('%s-%s-test-input-folder', raw_tiles_or_octree, freezing_or_thawing) ;
    input_folder_path = fullfile(path_to_this_folder, input_folder_name) ;
    compression_ratio = 10 ;  % only used for freezing
    do_run_on_cluster = false ;
    do_try = true ;  % if running locally, don't wrap in try so easier to debug
    maximum_running_slot_count = 40 ;
    submit_host_name = if_not_a_submit_host('login2.int.janelia.org') ;

    % Delete the test output folder
    reset_for_test(output_folder_path) ;

    % Make sure the input folder exists
    if ~logical(exist(input_folder_path, 'dir')) ,
        error('Input folder %s is missing, or is not a folder', input_folder_path) ;
    end

    % Call the script, but don't do verification
    if strcmp(freezing_or_thawing, 'freezing') ,
        freeze_mouselight_folder(...
            output_folder_path, ...
            input_folder_path, ...
            compression_ratio, ...
            do_run_on_cluster, ...
            do_try, ...
            maximum_running_slot_count, ...
            submit_host_name, ...
            'do_freezing', true, ...
            'do_verification', false) ;
    else
        thaw_mouselight_folder(...
            output_folder_path, ...
            input_folder_path, ...
            do_run_on_cluster, ...
            do_try, ...
            maximum_running_slot_count, ...
            submit_host_name, ...
            'do_thawing', true, ...
            'do_verification', false) ;
    end

    % Figure out what file we will mess with
    if strcmp(stack_or_non_stack, 'stack') ,
        if strcmp(freezing_or_thawing, 'freezing') ,
            if strcmp(raw_tiles_or_octree, 'octree') ,
                perverted_output_file_relative_path = '1/default.1.mj2' ;
            else
                perverted_output_file_relative_path = '2018-12-12/00/00241/00241-ngc.0.mj2' ;
            end
        else
            % thawing
            if strcmp(raw_tiles_or_octree, 'octree') ,
                perverted_output_file_relative_path = '1/default.1.tif' ;
            else
                perverted_output_file_relative_path = 'Tiling/2017-11-03/02/02013-ngc.0_comp-10.tif' ;
            end
        end
    else
        % non-stack file
        if strcmp(freezing_or_thawing, 'freezing') ,
            if strcmp(raw_tiles_or_octree, 'octree') ,
                perverted_output_file_relative_path = 'set_parameters.jl' ;
            else
                perverted_output_file_relative_path = '2018-12-09/02/02017/02017-ngc.microscope' ;
            end
        else
            % thawing 
            if strcmp(raw_tiles_or_octree, 'octree') ,
                perverted_output_file_relative_path = 'tilebase.cache.yml' ;
            else
                perverted_output_file_relative_path = 'Tiling/2017-11-03/02/02013-ngc.acquisition' ;
            end
        end
    end

    % Fake a failure by messing with one of the destination files
    perverted_output_file_path = fullfile(output_folder_path, perverted_output_file_relative_path) ;    
    if strcmp(exact_problem, 'deleted') ,
        delete(perverted_output_file_path) ;
    elseif strcmp(exact_problem, 'zero-length') ,
        delete(perverted_output_file_path) ;
        touch(perverted_output_file_path) ;        
    else         
        set_all_file_bytes_to_zero(perverted_output_file_path) ;
    end

    % Now do verification, which should fail
    try 
        if strcmp(freezing_or_thawing, 'freezing') ,
            freeze_mouselight_folder(...
                output_folder_path, ...
                input_folder_path, ...
                compression_ratio, ...
                do_run_on_cluster, ...
                do_try, ...
                maximum_running_slot_count, ...
                submit_host_name, ...
                'do_freezing', false, ...
                'do_verification', true) ;
        else
            thaw_mouselight_folder(...
                output_folder_path, ...
                input_folder_path, ...
                do_run_on_cluster, ...
                do_try, ...
                maximum_running_slot_count, ...
                submit_host_name, ...
                'do_thawing', false, ...
                'do_verification', true) ;            
        end
        error('Verification succeeded, even though a destination file was corrupted') ;
    catch me
        if strcmp(me.identifier, 'mouselight_toolbox:verification_failed') ,
            % All is well, nothing to do
            fprintf('Test %s %s %s %s %s passed.\n', ...
                    freezing_or_thawing, raw_tiles_or_octree, local_or_cluster, stack_or_non_stack, exact_problem) ;
        else
            rethrow(me) ;
        end           
    end    
end
