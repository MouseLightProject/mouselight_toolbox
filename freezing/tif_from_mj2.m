function tif_from_mj2(tif_output_folder_name, mj2_input_folder_name, do_verify, do_run_on_cluster)
    % Converts each .mj2 file in input_folder_name to a multi-image .tif in
    % output_folder_name.  Will overwrite pre-existing files in
    % output_folder_name, if present.
    
    if nargin<3 || isempty(do_verify) ,
        do_verify = false ;
    end
    if nargin<4 || isempty(do_run_on_cluster) ,
        do_run_on_cluster = false ;
    end
    
    if ~exist(tif_output_folder_name, 'dir') ,
        mkdir(tif_output_folder_name) ;
    end
    entity_names = setdiff(simple_dir(mj2_input_folder_name), {'.' '..'}) ;
    entity_count = length(entity_names) ;
    for i = 1 : entity_count ,
        mj2_input_entity_name = entity_names{i} ;        
        mj2_input_entity_path = fullfile(mj2_input_folder_name, mj2_input_entity_name) ;
        if exist(mj2_input_entity_path, 'dir') ,
            % if a folder, recurse
            tif_output_entity_path = fullfile(tif_output_folder_name, mj2_input_entity_name) ;
            tif_from_mj2(tif_output_entity_path, mj2_input_entity_path, do_verify, do_run_on_cluster) ;
        else
            % if a normal file, convert to .tif if it's a .mj2, or just
            % copy otherwise
            [~,~,ext] = fileparts(mj2_input_entity_path) ;
            if isequal(ext, '.mj2') ,
                tif_output_entity_path = fullfile(tif_output_folder_name, replace_extension(mj2_input_entity_name, '.tif')) ;
                if ~exist(tif_output_entity_path, 'file') ,
                    fprintf('Converting %s...\n', mj2_input_entity_path);
                    tic_id = tic() ;
                    scratch_folder_path = get_scratch_folder_path() ;
                    temporary_input_file_path = tempname(scratch_folder_path) ;
                    temporary_output_file_path = tempname(scratch_folder_path) ;                   
                    if do_run_on_cluster ,                        
                        command_line = ...
                            sprintf(['matlab -nojvm -singleCompThread ' ...
                                     '-r "mj2_entity_path = ''%s'';  tif_output_entity_path = ''%s''; do_verify = %s; ' ...
                                         'temporary_input_file_path = ''%s'';  temporary_output_file_path = ''%s''; ' ...                                     
                                         'copyfile(mj2_entity_path, temporary_input_file_path); ' ...
                                         'tif_from_mj2_single(temporary_output_file_path, temporary_input_file_path, do_verify); ' ...
                                         'copyfile(temporary_output_file_path, tif_output_entity_path); ' ...
                                         'delete(temporary_input_file_path); ' ...
                                         'delete(temporary_output_file_path); ' ...
                                         'exit"'], ...
                                    mj2_input_entity_path, ...
                                    tif_output_entity_path, ...
                                    fif(do_verify, 'true', 'false'),  ...
                                    temporary_input_file_path, ...
                                    temporary_output_file_path) ;
                        fprintf('Command line: %s\n', command_line) ;                        
                        bsub_command_line = sprintf('bsub -P mouselight -o /dev/null -e /dev/null %s', command_line) ;
                        fprintf('bsub Command line: %s\n', bsub_command_line) ;
                        system(bsub_command_line) ;
                    else
                        tif_from_mj2_single(tif_output_entity_path, mj2_input_entity_path, do_verify) ;
                    end
                    duration  = toc(tic_id) ;
                    fprintf('Took %g seconds\n', duration) ;
                end
            else
                tif_output_entity_path = fullfile(tif_output_folder_name, mj2_input_entity_name) ;
                if ~exist(tif_output_entity_path, 'file') ,
                    copyfile(mj2_input_entity_path, tif_output_entity_path) ;
                end
            end
        end
    end
end
