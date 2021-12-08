function [f, a] = figure_mip(stack_yxz)
    mip = max(stack_yxz, [], 3) ;

    c_min = double(min(min(mip))) ;
    c_max = double(max(max(mip))) ;
    if c_min == c_max ,
        c_mean = c_min ;
        c_min = c_mean - 0.5 ;
        c_max = c_mean + 0.5 ;
    end
    
    f = figure('color', 'w') ;
    a = axes(f) ;
    imagesc(a, mip, [c_min c_max]) ;
    axis(a,'image') ;
    colormap(parula(256)) ;
    colorbar;    
end
