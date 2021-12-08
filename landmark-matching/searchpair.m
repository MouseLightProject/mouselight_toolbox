function [X_,Y_,rate_,pixshift,nonuniformity, was_increase_shift_warning_hit] = ...
        searchpair(descent,descadjori,pixshiftinit,iadj,dims,matchparams, central_tile_ijk1)  %#ok<INUSD>
    
    pixshift = pixshiftinit;
    is_done = false ;
    R = zeros(1,10);
    
    [X_,Y_,rate_] = deal([]);
    was_increase_shift_warning_hit = false ;
    for iter = 1 : 50 ,   % run a search
        if is_done ,
            break
        end
        descadj = descadjori(:,1:3) + ones(size(descadjori,1),1)*pixshift ;  
          % translate the adjacent tile descriptors into the coordinate system of the
          % central tile
        
        z_lower_bound = max(pixshift(iadj),min(descadj(:,iadj)));  % lower bound on z coordinate of potentially matching fiducials
        z_upper_bound = min(dims(iadj),max(descent(:,iadj)))+3;  % upper bound on z coordinate of potentially matching fiducials
        X = descent(descent(:,iadj)>z_lower_bound&descent(:,iadj)<z_upper_bound,:);
        Y = descadj(descadj(:,iadj)>z_lower_bound&descadj(:,iadj)<z_upper_bound,:);
        X = X(:,1:3);
        Y = Y(:,1:3);
        
        if size(X,1)<3 || size(Y,1)<3 ,  % not enough fiducials to attempt matching
            [X_,Y_,rate_,pixshift,nonuniformity] = deal([]);
            is_done = true;
        else
            % check uniformity of data
            nbins = [2 2];
            edges = [];
            for ii = 1:2 ,
                minx = 0;
                maxx = dims(ii);
                binwidth = (maxx - minx) / nbins(ii);
                edges{ii} = minx + binwidth*(0:nbins(ii)); %#ok<AGROW>
            end
            [accArr] = hist3([X(:,1:2);Y(:,1:2)],'Edges',edges);
            accArr = accArr(1:2,1:2);
            if ~all(sum(accArr>mean(accArr(:))) & sum(accArr>mean(accArr(:)),2)')
                % non uniform over quad-representation
                nonuniformity(iter) = 1;
            else
                nonuniformity(iter) = 0;
            end
            
            try
                [rate,X_,Y_] = descriptorMatchforz(X,Y,pixshift,iadj,matchparams);
                if size(X_,1)<3
                    rate = 0; % overparametrized system
                end
                R(iter) = rate;
                if iter>1 && R(iter)-R(iter-1)<0
                    is_done = true;
                    X_ = X_t_1;
                    Y_ = Y_t_1;
                    rate = R(iter-1);
                else
                    X_t_1 = X_;
                    Y_t_1 = Y_;
                    if rate<.95 && iadj ==3   % no match
                        pixshift = pixshift + [0 0 5]; % expand more
                        is_done = false;  % is this necessary?
                        was_increase_shift_warning_hit = true ;
                        error('increase shift')
                    else % match found
                        is_done = true;
                    end
                end
                % store pairs
                rate_ = rate;
            catch me  %#ok<NASGU>
                X_ = [];
                Y_ = [];
                %fprintf('caught error "%s" for central tile [%d %d %d], ignoring\n', ...
                %        me.message, central_tile_ijk1(1), central_tile_ijk1(2), central_tile_ijk1(3) ) ;
            end
        end
    end
    
%     if was_increase_shift_warning_hit ,
%         fprintf('searchpair(): Caught at least one "increase shift" warning for central tile [%d %d %d], ignoring\n', ...
%                 central_tile_ijk1(1), central_tile_ijk1(2), central_tile_ijk1(3) ) ;
%     end        
end
