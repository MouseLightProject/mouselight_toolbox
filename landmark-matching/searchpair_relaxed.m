function [X_, Y_, rate_, pixshift, nonuniformity, X, Y_unshifted] = ...
        searchpair_relaxed(descent, descadjori, pixshiftinit, iadj, dims, matchparams)
    
    column_count = size(descent,2) ;  % Should be 3 + the descriptor count
    assert(column_count==3) ;
    
    pixshift = pixshiftinit;

    flag = 0;
    iter = 0;
    R = zeros(1,10);

    X_ = zeros(0,3) ;
    Y_ = zeros(0,3) ;
    %neigs_ = [] ;
    rate_ = [] ;
    while ~flag && iter<50 ,    % run a search
        %%
        iter = iter + 1;
        descadj = descadjori + pixshift ;

        nbound = [0 0];
        nbound(1) = max(pixshift(iadj),min(descadj(:,iadj)));
        nbound(2) = min(dims(iadj),max(descent(:,iadj)))+3;
        X = descent(descent(:,iadj)>nbound(1)&descent(:,iadj)<nbound(2),:);
        Y = descadj(descadj(:,iadj)>nbound(1)&descadj(:,iadj)<nbound(2),:);

        sizX = size(X,1);
        sizY = size(Y,1);
        tr = min(sizX,sizY);
        pD = pdist2(X(:,1:3),Y(:,1:3));
        [aa1,bb1]=min(pD,[],1);
        [aa2,bb2]=min(pD,[],2);
        keeptheseY = find([1:length(bb1)]'==bb2(bb1(:)));
        keeptheseX = bb1(keeptheseY)';
        disttrim = aa1(keeptheseY)'<25;
        X = X(keeptheseX(disttrim),:);
        Y = Y(keeptheseY(disttrim),:);
        ratew = sum(disttrim)/length(disttrim);
        %%
        if size(X,1)<3 || size(Y,1)<3 ,   % not enough sample to match
            X_ = zeros(0,3) ;
            Y_ = zeros(0,3) ;
            rate_ = [] ;
            nonuniformity = [] ;
            flag = 1 ;
        else
            %%
            % check uniformity of data
            nbins = [2 2];
            edges = [];
            for ii=1:2%length(dims)%[1 2 3],
                minx = 0;
                maxx = dims(ii);
                binwidth = (maxx - minx) / nbins(ii);
                edges{ii} = minx + binwidth*(0:nbins(ii));
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
                %%
                [rate,X_,Y_,tY_] = descriptorMatchforz_relaxed(X, Y, pixshift, iadj, matchparams) ;
                if size(X_,1)<3 ,
                    rate = 0 ;  % overparametrized system
                end
                R(iter) = rate;
                if iter>1 && R(iter)-R(iter-1)<0 ,
                    flag = 1;
                    X_ = X_t_1;
                    Y_ = Y_t_1;
                    rate = R(iter-1);
                else
                    X_t_1 = X_;
                    Y_t_1 = Y_;
                    if rate<.9 && iadj==3 ,  % no match
                        pixshift = pixshift + [0 0 5] ;  % expand more
                        flag = 0 ;
                        error('increased shift') ;
                    else % match found
                        flag = 1 ;
                    end
                end
                % store pairs
                rate_ = rate ;
            catch
                X_ = zeros(0,3) ;
                Y_ = zeros(0,3) ;
            end
        end
    end    
    Y_unshifted = Y - pixshift ;
end
