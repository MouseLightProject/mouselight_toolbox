function pass_and_run_count = test_all_eight_major_configurations()
    pass_count = 0 ;
    run_count = 0 ;
    for freezing_or_thawing = { 'freezing', 'thawing' } ,
        for raw_tiles_or_octree = { 'raw-tiles', 'octree' } ,
            for local_or_cluster = { 'local', 'cluster' } ,
                run_count = run_count + 1 ;
                try
                    test_single_major_configuration(freezing_or_thawing{1}, raw_tiles_or_octree{1}, local_or_cluster{1}) ;
                    pass_count = pass_count + 1 ;
                catch me
                    report = me.getReport() ;
                    fprint('Caught error while running test_single_major_configuration(''%s'', ''%s'', ''%s'').\nException report:\n%s', ...
                           freezing_or_thawing{1}, raw_tiles_or_octree{1}, local_or_cluster{1}, report) ;
                end
            end
        end
    end    
    pass_and_run_count = [pass_count run_count] ;
end
