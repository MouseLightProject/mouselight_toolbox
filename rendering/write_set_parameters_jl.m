function write_set_parameters_jl(set_parameters_jl_file_path, tilebase_file_path, notifications_email_address, is_p_map, ...
                                 octree_folder_path, ...
                                 shared_scratch_folder_path, ...
                                 log_scratch_folder_path)
                             
%     % Synthesize a single tag string that includes the sample tag and the analysis
%     % tag, if the later is nonempty    
%     if isempty(analysis_tag) ,
%         full_tag = sample_tag ;
%     else
%         full_tag = strcat(sample_tag,'-',analysis_tag) ;
%     end
    
    if ~exist('is_p_map', 'var') || isempty(is_p_map) ,
        is_p_map = false ;
    end
    
    this_folder_path = fileparts(mfilename('fullpath')) ;
    set_parameters_jl_template_file_path = fullfile(this_folder_path, 'set-parameters-template.jl') ;
    
    [tilebase_folder_path, tilebase_file_name] = fileparts2(tilebase_file_path) ;
    if ~strcmp(tilebase_file_name, 'tilebase.cache.yml') ,
        error('Tilebase file must be named tilebase.cache.yml') ;
    end
    
%     if is_p_map ,
%         octree_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s-prob', sample_tag) ;
%     else
%         octree_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s', sample_tag) ;
%     end        
%     shared_scratch_folder_path=sprintf('/nrs/mouselight/scratch/render-%s', full_tag) 
%     log_scratch_folder_path=sprintf('/groups/mousebrainmicro/mousebrainmicro/scratch/render-%s', full_tag)   % should be on /groups
    
    if is_p_map ,
        file_infix = 'prob' ;
        file_format_load = 'h5' ;
        file_format_save = 'h5' ;
    else
        file_infix = 'ngc' ;
        file_format_load = 'tif' ;
        file_format_save = 'tif' ;
    end
    
    set_parameters_jl_template = fileread(set_parameters_jl_template_file_path) ;
    set_parameters_jl_1 = strrep(set_parameters_jl_template, '$tilebase_folder_path', tilebase_folder_path) ;
    set_parameters_jl_2 = strrep(set_parameters_jl_1, '$octree_folder_path', octree_folder_path) ;
    set_parameters_jl_3 = strrep(set_parameters_jl_2, '$shared_scratch_folder_path', shared_scratch_folder_path) ;
    set_parameters_jl_4 = strrep(set_parameters_jl_3, '$log_scratch_folder_path', log_scratch_folder_path) ;
    set_parameters_jl_5 = strrep(set_parameters_jl_4, '$file_infix', file_infix) ;
    set_parameters_jl_6 = strrep(set_parameters_jl_5, '$file_format_load', file_format_load) ;
    set_parameters_jl_7 = strrep(set_parameters_jl_6, '$file_format_save', file_format_save) ;
    set_parameters_jl = strrep(set_parameters_jl_7, '$notifications_email_address', notifications_email_address) ;
    
    write_string_to_file(set_parameters_jl_file_path, set_parameters_jl) ;
end
