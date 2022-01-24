function [central_tile_ijk_from_match_index, ...
          other_tile_ijk_from_match_index, ...
          rate, ...
          other_tile_ijk_offset, ...
          nonuniformity, ...
          was_increase_shift_warning_hit, ...
          ijk_from_central_tile_border_landmark_index, ...
          ijk_from_other_tile_border_landmark_index] = ...
        searchpair(ijk_and_descriptors_from_central_tile_landmark_index, ...
                   ijk_and_descriptors_from_other_tile_landmark_index, ...
                   initial_other_tile_ijk_offset, ...
                   shift_axis_index, ...
                   stack_shape_ijk, ...
                   match_params, ...
                   central_tile_ijk1)  %#ok<INUSD>
    
    other_tile_ijk_offset = initial_other_tile_ijk_offset ;
    is_done = false ;
    R = zeros(1,10) ;
    
    % Drop the descriptors from the landmark coordinates
    ijk_from_central_tile_landmark_index = ijk_and_descriptors_from_central_tile_landmark_index(:,1:3) ;
    ijk_from_other_tile_landmark_index = ijk_and_descriptors_from_other_tile_landmark_index(:,1:3) ;

    [central_tile_ijk_from_match_index, other_tile_ijk_from_match_index, rate] = deal([]) ;
    was_increase_shift_warning_hit = false ;
    for iter = 1 : 50 ,   % run a search
        if is_done ,
            break
        end
        shifted_ijk_from_other_tile_landmark_index = ijk_from_other_tile_landmark_index + other_tile_ijk_offset ;  
          % translate the adjacent tile descriptors into the coordinate system of the
          % central tile
        
        z_lower_bound = ...
            max(other_tile_ijk_offset(shift_axis_index), ...
                min(shifted_ijk_from_other_tile_landmark_index(:,shift_axis_index))) ;   
            % lower bound on z coordinate of potentially matching fiducials
        z_upper_bound = ...
            min(stack_shape_ijk(shift_axis_index), ...
                max(ijk_from_central_tile_landmark_index(:,shift_axis_index))) +3 ;  
            % upper bound on z coordinate of potentially matching fiducials
        is_near_border_from_central_tile_landmark_index = ...
            z_lower_bound<ijk_from_central_tile_landmark_index(:,shift_axis_index) & ...
            ijk_from_central_tile_landmark_index(:,shift_axis_index)<z_upper_bound ;
        ijk_from_central_tile_border_landmark_index = ...
            ijk_from_central_tile_landmark_index(is_near_border_from_central_tile_landmark_index,:) ;
        
        is_near_border_from_other_tile_landmark_index = ...
            z_lower_bound<shifted_ijk_from_other_tile_landmark_index(:,shift_axis_index) & ...
            shifted_ijk_from_other_tile_landmark_index(:,shift_axis_index)<z_upper_bound ;
        shifted_ijk_from_other_tile_border_landmark_index = ...
            shifted_ijk_from_other_tile_landmark_index(is_near_border_from_other_tile_landmark_index,:);
        
        if size(ijk_from_central_tile_border_landmark_index,1)<3 || size(shifted_ijk_from_other_tile_border_landmark_index,1)<3 ,  % not enough fiducials to attempt matching
            central_tile_ijk_from_match_index = zeros(0,3) ;
            other_tile_ijk_from_match_index = zeros(0,3) ;
            rate = [] ;
            nonuniformity = [] ;
            is_done = true;
        else
            % check uniformity of data
            nbins = [2 2] ;
            edges = [] ;
            for ii = 1:2 ,
                minx = 0;
                maxx = stack_shape_ijk(ii);
                binwidth = (maxx - minx) / nbins(ii);
                edges{ii} = minx + binwidth*(0:nbins(ii)); %#ok<AGROW>
            end
            [accArr] = hist3([ijk_from_central_tile_border_landmark_index(:,1:2);shifted_ijk_from_other_tile_border_landmark_index(:,1:2)],'Edges',edges);
            accArr = accArr(1:2,1:2) ;
            if ~all(sum(accArr>mean(accArr(:))) & sum(accArr>mean(accArr(:)),2)')
                % non uniform over quad-representation
                nonuniformity(iter) = 1;
            else
                nonuniformity(iter) = 0;
            end
            
            try
                [rate_for_this_iteration, central_tile_ijk_from_match_index, other_tile_ijk_from_match_index] = ...
                    descriptorMatchforz(ijk_from_central_tile_border_landmark_index, ...
                                        shifted_ijk_from_other_tile_border_landmark_index, ...
                                        other_tile_ijk_offset, ...
                                        shift_axis_index,match_params) ;
                if size(central_tile_ijk_from_match_index,1)<3
                    rate_for_this_iteration = 0; % overparametrized system
                end
                R(iter) = rate_for_this_iteration;
                if iter>1 && R(iter)-R(iter-1)<0
                    is_done = true;
                    central_tile_ijk_from_match_index = X_t_1;
                    other_tile_ijk_from_match_index = Y_t_1;
                    rate_for_this_iteration = R(iter-1);
                else
                    X_t_1 = central_tile_ijk_from_match_index;
                    Y_t_1 = other_tile_ijk_from_match_index;
                    if rate_for_this_iteration<.95 && shift_axis_index ==3   % no match
                        other_tile_ijk_offset = other_tile_ijk_offset + [0 0 5] ;  % expand more
                        is_done = false;  % is this necessary?
                        was_increase_shift_warning_hit = true ;
                        error('increase shift')
                    else % match found
                        is_done = true;
                    end
                end
                % store pairs
                rate = rate_for_this_iteration;
            catch me  %#ok<NASGU>
                central_tile_ijk_from_match_index = [];
                other_tile_ijk_from_match_index = [];
                %fprintf('caught error "%s" for central tile [%d %d %d], ignoring\n', ...
                %        me.message, central_tile_ijk1(1), central_tile_ijk1(2), central_tile_ijk1(3) ) ;
            end
        end
    end
    
    ijk_from_other_tile_border_landmark_index = shifted_ijk_from_other_tile_border_landmark_index - other_tile_ijk_offset ;
%     if was_increase_shift_warning_hit ,
%         fprintf('searchpair(): Caught at least one "increase shift" warning for central tile [%d %d %d], ignoring\n', ...
%                 central_tile_ijk1(1), central_tile_ijk1(2), central_tile_ijk1(3) ) ;
%     end        
end
