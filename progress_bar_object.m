classdef progress_bar_object < handle
    properties
        n_
        percent_as_displayed_last_
        did_print_at_least_one_line_
    end
    
    methods
        function self = progress_bar_object(n)
            self.n_ = n ;
            self.percent_as_displayed_last_ = [] ;
            self.did_print_at_least_one_line_ = false ;
        end
        
        function update(self, i)
            n =self.n_ ;
            percent = 100*(i/n) ;    
            percent_as_displayed = round(percent*10)/10 ;    
            if ~isequal(percent_as_displayed, self.percent_as_displayed_last_) ,
                if self.did_print_at_least_one_line_ ,
                    delete_bar = repmat('\b', [1 1+50+1+2+4+1]) ;
                    fprintf(delete_bar) ;
                end
                bar = repmat('*', [round(percent/2) 1]) ;
                fprintf('[%-50s]: %4.1f%%', bar, percent_as_displayed) ;
                self.did_print_at_least_one_line_ = true ;
            end
            if i==n ,
                fprintf('\n') ;
            end
            self.percent_as_displayed_last_ = percent_as_displayed ;
        end
    end
end
