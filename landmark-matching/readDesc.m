function des = readDesc(inputfolder, channel_index, ext_desc)
    % The original code for this seems very complicated.  We'll so something simpler.
    
    % Parse args
    if isempty(channel_index) ,
        error('readDesc() needs a channel index') ;
    end
    if ~(channel_index==0 || channel_index==1) ,
        error('readDesc(): Channel must be 0 or 1') ;
    end
    if ~exist('ext_desc', 'var') || isempty(ext_desc) ,
        ext_desc = 'txt';
    end    
    
    % Synthesize the full file path
    [~, folder_name] = fileparts2(inputfolder) ;
    file_name = sprintf('%s-desc.%d.%s', folder_name, channel_index, ext_desc) ;
    file_path = fullfile(inputfolder, file_name) ;
    
    % Load the descriptors
    des = load('-ascii', file_path) ;
end
