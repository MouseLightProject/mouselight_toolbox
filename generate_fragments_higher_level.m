function generate_fragments_higher_level(sample_date, ...
                                         file_format, ...
                                         minimum_centerpoint_count_per_fragment, ...
                                         bounding_box_low_corner_xyz, ...
                                         bounding_box_high_corner_xyz)
                                     
    fprintf('\n\nGenerating fragments...\n') ;                                     
    outer_tic_id = tic() ;
                                     
    % Set paths, etc                                             
    input_folder_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/full-as-named-tree-mats', ...
                sample_date) ;
    output_folder_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/frags-with-5-or-more-nodes', ...
                sample_date) ;       
    maximum_core_count_desired = inf ;
                                             
    % Get the pool ready
    use_this_many_cores(maximum_core_count_desired) ;
    
    if ~exist(output_folder_path, 'dir') ,
        mkdir(output_folder_path) ;
    end
    full_tree_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*.mat')) ;
    full_trees_to_process_count = length(full_tree_file_names) ;
    %tic_id = tic() ;
    fprintf('Starting the for loop to process trees, going to process %d full trees...\n', full_trees_to_process_count) ;
    pbo = progress_bar_object(full_trees_to_process_count) ;
    %parfor_progress(full_trees_to_process_count) ;
    for full_tree_index = 1 : full_trees_to_process_count ,
        full_tree_file_name = full_tree_file_names{full_tree_index} ;
        full_tree_mat_file_path = fullfile(input_folder_path, full_tree_file_name) ;
        named_tree = load_named_tree_from_mat(full_tree_mat_file_path) ;
        generate_fragments_from_named_tree(output_folder_path, ...
                                           named_tree, ...
                                           file_format, ...
                                           minimum_centerpoint_count_per_fragment, ...
                                           bounding_box_low_corner_xyz, ...
                                           bounding_box_high_corner_xyz) ;
        
        % Update the progress bar
        %parfor_progress() ;
        pbo.update(full_tree_index) ;
    end
    %parfor_progress(0) ;
    pbo.finish_up() ;
    %toc(tic_id) ;

    % Count the number of fragments
    command_line = sprintf('ls -U "%s" | wc -l', output_folder_path) ;
    [status, stdout] = system(command_line) ;
    if status ~= 0 ,
        error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
    end
    fragment_count = str2double(stdout) ;
    if ~isfinite(fragment_count) ,
        error('There was a problem running the command %s.  Unable to parse output.  Output was: %s', command_line, stdout) ;
    end    
    fprintf('Fragment count: %d\n', fragment_count) ;
    
    elapsed_time = toc(outer_tic_id) ;
    fprintf('Done generating fragments.  Elapsed time to generate fragments: %g sec.\n', elapsed_time) ;
end
