function passed_count_and_run_count = test_all()
    function_name_from_test_index = {'test_all_eight_major_configurations', 'test_all_verification_conditions' } ;
    cell_results_from_test_index = cellfun(@feval, function_name_from_test_index, 'UniformOutput', false) ;
    results_from_test_index = cell2mat(cell_results_from_test_index') ;  % test_count x 2, 1st col subtests passed, 2nd col subtests run
    passed_count_and_run_count = sum(results_from_test_index, 1) ;
    passed_count = passed_count_and_run_count(1) ;
    run_count = passed_count_and_run_count(2) ;
    fprintf('Test summary: %d passed out of %d tests run.\n', passed_count, run_count) ;
end
