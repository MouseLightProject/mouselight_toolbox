% Specify the input/output folders
sample_tag = '2021-03-17-region-1'  %#ok<NOPTS>
analysis_tag = 'adam-classifier-z-match-count-threshold-50' 
this_folder_path = fileparts(mfilename('fullpath')) ;
tile_folder_path = '/groups/mousebrainmicro/mousebrainmicro/data/test-data/test-unscaled/2021-03-17-region1'
pipeline_output_folder = '/nrs/mouselight/pipeline_output/test-unscaled/2021-03-17-region-1-with-adam-classifier'
sample_memo_folder_path = fullfile(this_folder_path, 'memos', sample_tag) ;
analysis_memo_folder_path = fullfile(sample_memo_folder_path, analysis_tag) ;
stitching_output_folder_path = fullfile(analysis_memo_folder_path, 'stitching-output') ;
vecfield3D_file_path = '/groups/mousebrainmicro/mousebrainmicro/users/taylora/pipeline-stitching/memos/2021-03-17-test-unscaled-region-1/adam-classifier/stitching-output/vecfield3D.mat'
notifications_email_address = 'taylora@hhmi.org' ;

% Call the function that does the real work
render(sample_tag, ...
       analysis_tag, ...
       tile_folder_path, ...
       vecfield3D_file_path, ...
       analysis_memo_folder_path, ...
       notifications_email_address) ;
