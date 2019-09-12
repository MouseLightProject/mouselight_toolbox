function use_this_many_cores(core_count_desired)
    poolobj = gcp('nocreate') ;  % If no pool, do not create new one.
    if isempty(poolobj) ,                
        parpool_fancy(core_count_desired) ;        
    else
        core_count = poolobj.NumWorkers ;
        if core_count ~= core_count_desired ,
            delete(poolobj) ;
            parpool_fancy(core_count_desired) ;
        end
    end
    poolobj = gcp('nocreate');  % If no pool, do not create new one.  But there should be one at this point...
    core_count = poolobj.NumWorkers ;
    fprintf('Using %d cores.\n', core_count) ;
end


function parpool_fancy(core_count_desired)
    % Like parpool, but deals if core_count_desired is inf
    if isinf(core_count_desired) ,
        physical_core_count = feature('numcores') ;
        core_count_we_will_request = physical_core_count ;
    else
        core_count_we_will_request = core_count_desired ;
    end
    parpool(core_count_we_will_request) ;
end
