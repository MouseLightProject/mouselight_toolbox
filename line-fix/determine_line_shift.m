function shift = determine_line_shift(raw_stack, min_shift, max_shift, do_run_in_debug_mode)    
    % binarize it to eliminate spatial non-uniformity bias
    serial_stack = double(raw_stack(:)) ;
    middle_value = mean(quantile(serial_stack,[0.0001 0.9999])) ;
    stack = (raw_stack>middle_value) ;
    [shift, shift_float] = determine_line_shift_core(stack, min_shift, max_shift, false, do_run_in_debug_mode) ;
    % check if shift is closer to halfway. 0.4<|shift-round(shift)|<0.6
    if abs(abs(round(shift_float,2)-round(shift_float,0))-0.5) < 0.1 ,
        [shift, shift_float] = determine_line_shift_core(stack, min_shift, max_shift, true, do_run_in_debug_mode) ;  %#ok<ASGLU>
    end
end
