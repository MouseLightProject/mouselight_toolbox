function [paireddescriptor, iadj] = pointmatch_core(desc1, desc2, scopefile1, scopefile2, pixshift, maxnumofdesc, central_tile_ijk1)
    % Version of pointmatch that does the core computation, and doesn't touch the
    % filesystem.
    if ~exist('pixshift', 'var') || isempty(pixshift) ,
        pixshift = [0 0 0] ;
    end
    if ~exist('maxnumofdesc', 'var') || isempty(maxnumofdesc) ,
        maxnumofdesc=1e3 ;
    end
    if ~exist('central_tile_ijk1', 'var') || isempty(central_tile_ijk1) ,
        central_tile_ijk1 = [nan nan nan] ;
    end

    dims = [1024,1536,251] ;
    projectionThr = 5 ;
    debug = 0 ;

    %tag = 'XYZ';
    %scopefile1 = readScopeFile(acqusitionfolder1);
    %scopefile2 = readScopeFile(acqusitionfolder2);
    imsize_um = [scopefile1.x_size_um,scopefile1.y_size_um,scopefile1.z_size_um];
    % estimate translation
    gridshift = ([scopefile2.x scopefile2.y scopefile2.z]-[scopefile1.x scopefile1.y scopefile1.z]);
    iadj =find(gridshift);
    stgshift = 1000*([scopefile2.x_mm scopefile2.y_mm scopefile2.z_mm]-[scopefile1.x_mm scopefile1.y_mm scopefile1.z_mm]);
    if all(pixshift==0)
        pixshift = round(stgshift.*(dims-1)./imsize_um);
    end

    %%
    % read descs
    %desc1 = readDesc(tile1,channel_index);
    %desc2 = readDesc(tile2,channel_index);
    % check if input exists
    if isempty(desc1) || isempty(desc2) ,
        rate_ = 0;
        X_ = [];
        Y_ = [];
        uni = 0;
        was_increase_shift_warning_hit = false ;
    else
        % correct images, xy flip
        desc1 = correctTiles(desc1,dims);
        desc2 = correctTiles(desc2,dims);
        % truncate descriptors
        desc1 = truncateDesc(desc1,maxnumofdesc);
        desc2 = truncateDesc(desc2,maxnumofdesc);
        if isempty(desc1) || isempty(desc2) ,
            rate_ = 0;
            X_ = [];
            Y_ = [];
            uni = 0;
        else
            % idaj : 1=right(+x), 2=bottom(+y), 3=below(+z)
            % pixshift(iadj) = pixshift(iadj)+expensionshift(iadj); % initialize with a relative shift to improve CDP
            matchparams = modelParams(projectionThr,debug);
            if length(iadj)~=1 || max(iadj)>3
                error('not 6 direction neighbor')
            end
            %% MATCHING
            [X_,Y_,rate_,~,nonuniformity, was_increase_shift_warning_hit] = ...
                searchpair(desc1,desc2,pixshift,iadj,dims,matchparams, central_tile_ijk1);
            if isempty(X_)
                matchparams_ = matchparams;
                matchparams_.opt.outliers = .5;
                [X_,Y_,rate_,~,nonuniformity] = searchpair_relaxed(desc1(:,1:3),desc2(:,1:3),pixshift,iadj,dims,matchparams_);
            end

            if ~isempty(X_)
                X_ = correctTiles(X_,dims);
                Y_ = correctTiles(Y_,dims);
            end
            uni = mean(nonuniformity)<=.5;
        end
    end

    % Package things up in s struct to return
    paireddescriptor = struct() ;
    paireddescriptor.matchrate = rate_;
    paireddescriptor.X = X_;
    paireddescriptor.Y = Y_;
    paireddescriptor.uni = uni;
    paireddescriptor.was_increase_shift_warning_hit = was_increase_shift_warning_hit ;    
end











