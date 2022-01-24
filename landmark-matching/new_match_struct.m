function match_struct = new_match_struct(match_rate, central_tile_ijk_from_match_index, other_tile_ijk_from_match_index, uni, was_increase_shift_warning_hit)
    % Return a struct used to encapsulate results of matching.
    if nargin==0 ,
        match_rate = 0 ;
        central_tile_ijk_from_match_index = zeros(0,3) ;
        other_tile_ijk_from_match_index = zeros(0,3) ;
        uni = 0 ;
        was_increase_shift_warning_hit = false ;
    end
    match_struct = struct() ;
    match_struct.matchrate = match_rate;
    match_struct.X = central_tile_ijk_from_match_index ;
    match_struct.Y = other_tile_ijk_from_match_index ;
    match_struct.uni = uni ;
    match_struct.was_increase_shift_warning_hit = was_increase_shift_warning_hit ;
end
