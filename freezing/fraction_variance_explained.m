function result = fraction_variance_explained(output_stack, input_stack)
    % Compute the fraction of the variance in the input stack which is explained
    % by the output stack.  This is just a gross check that the output is close to
    % the input.
    if isequal(class(output_stack), class(input_stack)) && isequal(size(output_stack), size(input_stack)) ,
        if all(all(all(output_stack==input_stack))) ,
            result = 1 ;
        else
            output_stack_serial = double(output_stack(:)) ;
            input_stack_serial = double(input_stack(:)) ;
            input_mean = mean(input_stack_serial) ;
            
            residual_variance = mean( (output_stack_serial-input_stack_serial).^2 ) ;
            %sqrt_residual_variance = sqrt(residual_variance) 
            total_variance = mean( (input_stack_serial-input_mean).^2 )  ;
            %sqrt_total_variance = sqrt(total_variance) 
            
            if residual_variance == 0 ,                
                % If residual variance is 0, want the output to be 1, even if total variance
                % is also zero.  (The general expression below will be nan if both are zero.)
                result = 1 ;
            else
                result = 1 - residual_variance/total_variance ;  
                    % this can actually be negative, since the output_stack is not a generally a regression
            end
        end
    else
        result = 0 ;
    end
end
