% Specify the input/output folders
sample_tag = '2021-10-29'  %#ok<NOPTS>
analysis_tag = 'production-classifier-z-match-count-threshold-50-alt'
if isempty(analysis_tag) ,
    full_tag = sample_tag 
else
    full_tag = strcat(sample_tag,'-',analysis_tag) 
end
this_folder_path = fileparts(mfilename('fullpath')) ;
tile_folder_path = sprintf('/groups/mousebrainmicro/mousebrainmicro/data/%s/Tiling', sample_tag) 
pipeline_output_folder = sprintf('/nrs/mouselight/pipeline_output/%s', sample_tag) 
sample_memo_folder_path = fullfile('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions', sample_tag) 
analysis_memo_folder_path = fullfile(sample_memo_folder_path, analysis_tag) 
stitching_output_folder_path = fullfile(analysis_memo_folder_path, 'stitching-output') 
vecfield3D_file_path = fullfile(stitching_output_folder_path, 'vecfield3D.mat') 
notifications_email_address = 'taylora@hhmi.org' ;
is_p_map = false ;
if is_p_map ,
    octree_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s-prob', sample_tag) 
else
    octree_folder_path = sprintf('/nrs/mouselight/SAMPLES/%s', sample_tag) ;
end
render_shared_scratch_folder_path=sprintf('/nrs/mouselight/scratch/render-%s', full_tag)
render_log_scratch_folder_path=sprintf('/groups/mousebrainmicro/mousebrainmicro/scratch/render-%s', full_tag)   % should be on /groups

% Call the function that does the real work
render(full_tag, ...
       tile_folder_path, ...
       vecfield3D_file_path, ...
       analysis_memo_folder_path, ...
       notifications_email_address, ...
       is_p_map, ...
       octree_folder_path, ...
       render_shared_scratch_folder_path, ...
       render_log_scratch_folder_path) ;
