function [result, is_folder, file_size, datenum] = simple_dir(template)
    s = dir(template) ;
    raw_result = {s.name} ;
    raw_is_folder = [s.isdir] ;
    raw_file_size = cellfun(@(x)(fif(isempty(x),nan,x)), {s.bytes}) ;
        % You'd think raw_file_size = [s.bytes] would work, but for symlinks s(i).bytes is [],
        % so we want to replace those with some scalar double.
    raw_datenum = [s.datenum] ;
    [~,indices_of_keepers] = setdiff(raw_result, {'.' '..'}) ;
    result = raw_result(indices_of_keepers) ;
    is_folder = raw_is_folder(indices_of_keepers) ;
    file_size = raw_file_size(indices_of_keepers) ;
    datenum = raw_datenum(indices_of_keepers) ;
end
