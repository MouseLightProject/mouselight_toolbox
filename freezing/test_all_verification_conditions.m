function pass_and_run_count = test_all_verification_conditions()
    pass_count = 0 ;
    run_count = 0 ;
    for freezing_or_thawing = { 'freezing', 'thawing' } ,
    %for freezing_or_thawing = { 'thawing' } ,
        for raw_tiles_or_octree = { 'raw-tiles', 'octree' } ,
        %for raw_tiles_or_octree = { 'octree' } ,
            for local_or_cluster = { 'local', 'cluster' } ,
            %for local_or_cluster = { 'local' } ,
                for stack_or_non_stack = { 'stack', 'non-stack' } ,
                    for exact_problem = { 'deleted', 'zero-length', 'corrupt' } ,
                        run_count = run_count + 1 ;
                        try
                            test_verification_condition( ...
                                freezing_or_thawing{1}, raw_tiles_or_octree{1}, local_or_cluster{1}, stack_or_non_stack{1}, exact_problem{1}) ;
                            pass_count = pass_count + 1 ;
                        catch me
                            report = me.getReport() ;
                            fprint('Caught error while running test_verification_condition(''%s'', ''%s'', ''%s'', ''%s'', ''%s'').\nException report:\n%s', ...
                                   freezing_or_thawing{1}, raw_tiles_or_octree{1}, local_or_cluster{1}, stack_or_non_stack{1}, exact_problem{1}, report) ;
                        end                        
                    end
                end
            end
        end
    end    
    pass_and_run_count = [pass_count run_count] ;    
end
