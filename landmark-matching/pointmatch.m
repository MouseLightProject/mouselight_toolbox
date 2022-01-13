function exitcode = pointmatch(tile1, tile2, acqusitionfolder1, acqusitionfolder2, output_folder_name, pixshift, central_tile_ijk1, maxnumofdesc, exitcode)
    % Front-end function to do z point-matching in the Patrick pipeline.  In this
    % version, the ch argument is vestigial---it is completely ignored
    
    % Deal with arguments
    if ~exist('pixshift', 'var') || isempty(pixshift) ,
        pixshift = '[0 0 0]' ;
    end
    if ~exist('central_tile_ijk1', 'var') || isempty(central_tile_ijk1) ,
        central_tile_ijk1 = [nan nan nan] ;
    end
    if ~exist('maxnumofdesc', 'var') || isempty(maxnumofdesc) ,
        maxnumofdesc=1e3 ;
    end
    if ~exist('exitcode', 'var') || isempty(exitcode) ,
        exitcode = 0 ;
    end
    
    % Eval args that are strings that (hopefully) represent numeric arrays
    if ischar(pixshift)
        pixshift = eval(pixshift);
    end
    if ischar(maxnumofdesc)
        maxnumofdesc=str2double(maxnumofdesc);
    end
    if ischar(exitcode)
        exitcode=str2double(exitcode);
    end
    
    % Read in stuff from input files
    scopefile1 = readScopeFile(acqusitionfolder1);
    scopefile2 = readScopeFile(acqusitionfolder2);
    
    X_for_all_channels = zeros(0,3) ;
    Y_for_all_channels = zeros(0,3) ;
    for channel_index = 0:1 ,
        desc1 = readDesc(tile1, channel_index) ;
        desc2 = readDesc(tile2, channel_index) ;

        % Call the function that does the real work
        [paireddescriptor, iadj] = pointmatch_core(desc1, desc2, scopefile1, scopefile2, pixshift, maxnumofdesc, central_tile_ijk1) ;

        % Write the main output file
        tag = 'XYZ';
        axis_letter = tag(iadj) ;
        ensure_folder_exists(output_folder_name) ;
        output_file_leaf_name = sprintf('channel-%d-match-%s.mat', channel_index, axis_letter) ;
        output_file_name = fullfile(output_folder_name, output_file_leaf_name) ;
        if exist(output_file_name,'file')
            unix(sprintf('rm -f %s',output_file_name)) ;
        end
        save(output_file_name,'paireddescriptor','scopefile1','scopefile2')
        system(sprintf('chmod g+rw %s',output_file_name));

        % Save points for making the thumbnail
        X_for_all_channels = vertcat(X_for_all_channels, paireddescriptor.X) ;  %#ok<AGROW>
        Y_for_all_channels = vertcat(Y_for_all_channels, paireddescriptor.Y) ;  %#ok<AGROW>        
    end
    
    % Synthesize and write a thumbnail image file
    % x:R, y:G, z:B
    if isempty(X_for_all_channels) ,
        col = [0 0 0] ;  % black as night
    else
        col = median(Y_for_all_channels-X_for_all_channels,1)+128;
    end    
    col = max(min(col,255),0);
    outpng = zeros(105,89,3);
    outpng(:,:,1) = col(1);
    outpng(:,:,2) = col(2);
    outpng(:,:,3) = col(3);
    thumbnail_image_file_name = fullfile(output_folder_name,'Thumbs.png') ;
    if exist(thumbnail_image_file_name,'file')
        system(sprintf('rm -f %s',thumbnail_image_file_name)) ;
    end
    imwrite(outpng,thumbnail_image_file_name)
    system(sprintf('chmod g+rw %s',thumbnail_image_file_name));
end
