function result = simple_dir(template)
    s = dir(template) ;
    raw_result = {s.name} ;
    result = setdiff(raw_result, {'.' '..'}) ;
end
