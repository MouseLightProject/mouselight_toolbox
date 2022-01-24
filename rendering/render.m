function render(full_tag, ...
                tile_folder_path, ...
                vecfield3D_file_path, ...
                analysis_memo_folder_path, ...
                notifications_email_address, ...
                is_p_map, ...
                octree_folder_path, ...
                shared_scratch_folder_path, ...
                log_scratch_folder_path)
    % Synthesize a single tag string that includes the sample tag and the analysis
    % tag, if the later is nonempty    
    if ~exist('is_p_map', 'var') || isempty(is_p_map) ,
        is_p_map = false ;
    end
    
    % Load in the vecfield3D file, which is roughly the .mat version of the
    % tilebase.cache.yml file
    load(vecfield3D_file_path, 'vecfield3D', 'params') ;
    
    % Output a tilebase.cache.yml file we'll feed into the renderer
    % This ensures the name ofthe file is "tilebase.cache.yml", which is required by
    % the renderer.
    % It also allows us to write the initial path: field in the tilebase.cache.yml
    % file to what we want it to be.
    tilebase_file_path = fullfile(analysis_memo_folder_path, 'tilebase.cache.yml') ;
    ensure_file_does_not_exist(tilebase_file_path) ;
    is_big = 1 ;  % true means to do the full barycentric version
    ymldims = [params.imagesize 2];  % [1024 1536 251 2]
    tile_count = length(vecfield3D.path) ;
    targetidx = (1:tile_count) ;
    writeYML(tilebase_file_path, targetidx, vecfield3D, is_big, ymldims, tile_folder_path) ;

    % Write out the renderer parameter specification file
    set_parameters_jl_file_name = sprintf('set-parameters-%s.jl', full_tag) ;
    set_parameters_jl_file_path = fullfile(analysis_memo_folder_path, set_parameters_jl_file_name) ;
    write_set_parameters_jl(set_parameters_jl_file_path, tilebase_file_path, notifications_email_address, is_p_map, ...
                            octree_folder_path, ...
                            shared_scratch_folder_path, ...
                            log_scratch_folder_path) ;
    
    % Finally, invoke the renderer
    system_from_list_with_error_handling( ...
        {'/groups/mousebrainmicro/mousebrainmicro/Software/barycentric5/src/render/src/render', ...
         set_parameters_jl_file_path}) ;
end
