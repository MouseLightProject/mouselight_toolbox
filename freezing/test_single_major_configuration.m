function test_single_major_configuration(freezing_or_thawing, raw_tiles_or_octree, local_or_cluster)
    % Test, in one of 2^3==8 possible configurations.
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
    
    % Define all the needed inputs
    path_to_this_folder = fileparts(mfilename('fullpath')) ;
    output_folder_name = sprintf('%s-%s-test-output-folder', raw_tiles_or_octree, freezing_or_thawing) ;
    output_folder_path = fullfile(path_to_this_folder, output_folder_name) ;
    input_folder_name = sprintf('%s-%s-test-input-folder', raw_tiles_or_octree, freezing_or_thawing) ;
    input_folder_path = fullfile(path_to_this_folder, input_folder_name) ;
    compression_ratio = 10 ;  % only used for freezing
    do_run_on_cluster = strcmp(local_or_cluster, 'cluster') ;
    do_try = false ;  % if running locally, don't wrap in try so easier to debug
    maximum_running_slot_count = 40 ;
    submit_host_name = if_not_a_submit_host('login2.int.janelia.org') ;

    % Delete the test output folder
    reset_for_test(output_folder_path) ;

    % Make sure the input folder exists
    if ~logical(exist(input_folder_path, 'dir')) ,
        error('Input folder %s is missing, or is not a folder', input_folder_path) ;
    end

    % Call the script
    if strcmp(freezing_or_thawing, 'freezing') ,
        freeze_mouselight_folder(...
            output_folder_path, ...
            input_folder_path, ...
            compression_ratio, ...
            do_run_on_cluster, ...
            do_try, ...
            maximum_running_slot_count, ...
            submit_host_name) ;
    else
        thaw_mouselight_folder(...
            output_folder_path, ...
            input_folder_path, ...
            do_run_on_cluster, ...
            do_try, ...
            maximum_running_slot_count, ...
            submit_host_name) ;        
    end
end
