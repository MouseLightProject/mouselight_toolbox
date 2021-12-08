function lpl_process_single_tile_channel(raw_tile_file_name, tile_relative_path, input_root_path, p_map_root_path, landmarks_root_path, ...
                                         do_force_computation, do_run_in_debug_mode)                                    
    % Deal with args
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end

    % Compute the p-map file path
    input_file_path = fullfile(input_root_path, tile_relative_path, raw_tile_file_name) ;
    [~,day_tile_index_as_string] = fileparts2(tile_relative_path) ;
    channel_index0_as_string = channel_index0_as_string_from_tile_file_name(raw_tile_file_name) ;
    p_map_file_name = sprintf('%s-prob.%s.h5', day_tile_index_as_string, channel_index0_as_string) ;
    p_map_tile_folder_path = fullfile(p_map_root_path, tile_relative_path) ;
    p_map_file_path = fullfile(p_map_tile_folder_path, p_map_file_name) ;
    
    % Shell out to run Ilastik
    if do_force_computation || ~exist(p_map_file_path, 'file') ,   
        ensure_folder_exists(p_map_tile_folder_path) ;
        
        %script_path = mfilename('fullpath') ;
        %script_folder_path = fileparts(script_path) ;
        %ilastik_project_path = fullfile(script_folder_path, '/groups/mousebrainmicro/mousebrainmicro/pipeline-systems axon-classifier/axon_uint16.ilp') ;
        ilastik_project_path = '/groups/mousebrainmicro/mousebrainmicro/pipeline-systems/pipeline-a/apps/axon-classifier/axon_uint16.ilp' ;
        IL_PREFIX = '/groups/mousebrainmicro/mousebrainmicro/pipeline-systems/tools/ilastik-1.1.9-Linux' ;
        %IL_PREFIX = '/groups/mousebrainmicro/mousebrainmicro/Software/ilastik-1.3.3post2-Linux' ;
        %IL_PREFIX = '/groups/mousebrainmicro/mousebrainmicro/Software/ilastik-1.3.3-Linux' ;
        output_format = 'hdf5' ; 
        %'multipage tiff', 'multipage tiff sequence', 'hdf5'
        python_path = fullfile(IL_PREFIX, 'bin/python') ;
        ilastik_dot_py_path = fullfile(IL_PREFIX, 'ilastik-meta/ilastik/ilastik.py') ;
        %command_line = sprintf(['export LAZYFLOW_THREADS=4 ; ' ...
        %                        'export LAZYFLOW_TOTAL_RAM_MB=60000 ; ' ...
        %                        '"%s" ' ...
        command_line = sprintf(['export LAZYFLOW_THREADS=4 ; ' ...
                                'export LAZYFLOW_TOTAL_RAM_MB=60000 ; ' ...
                                '"%s" ' ...
                                '"%s" ' ...
                                '--headless ' ...
                                '--readonly 1 ' ...
                                '--cutout_subregion="[(None,None,None,0),(None,None,None,1)]" ' ...
                                '--project="%s" ' ...
                                '--output_filename_format="%s" ' ...
                                '--output_format="%s" ' ...
                                '"%s"'] , ...
                               python_path, ...
                               ilastik_dot_py_path, ...
                               ilastik_project_path, ...
                               p_map_file_path, ...
                               output_format, ...
                               input_file_path) ;                           
        fprintf('Ilastik command line: %s\n', command_line) ;                   
        system_with_error_handling(command_line) ;   
    end

    % Generate the landmarks from the p-map
    landmark_file_name = sprintf('%s-desc.%s.txt', day_tile_index_as_string, channel_index0_as_string) ;
    landmark_folder_path = fullfile(landmarks_root_path, tile_relative_path) ;
    landmark_file_path = fullfile(landmark_folder_path, landmark_file_name) ;

    % Make sure the output folder exists
    ensure_folder_exists(landmark_folder_path) ;
    
    % Run the core code
    siz = '[11 11 11]' ;
    sig1 = '[3.405500 3.405500 3.405500]' ;
    sig2 = '[4.049845 4.049845 4.049845]' ;
    ROI = '[5 1019 5 1531 5 250]' ;
    rt = '4' ;    
    exitcode = dogDescriptor(p_map_file_path, landmark_file_path, siz, sig1, sig2, ROI, rt) ;
    if exitcode ~= 0 ,
        error('dogDescriptor() returned a nonzero exit code (%s) when trying to produce output file %s', exitcode, landmark_file_path) ;
    end
end
