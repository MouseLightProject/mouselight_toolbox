function [regpts,featmap] = loadMatchedFeaturesNewZ(scopeloc, descriptorfolder, matching_channel_index, featmap, does_use_new_style_z_match_file_names)
% get list file
tile_count = size(scopeloc.loc,1);

direction = 'Z' ;  % only check z

if ~exist('featmap', 'var') || isempty(featmap) ,
    for tile_index=1:tile_count
        [featmap(tile_index).X,featmap(tile_index).Y,featmap(tile_index).Z] = deal([]);
    end
end

% Make the index that allows us to quickly determine when a tile has a neighbor
% tile
[does_exist_from_tile_ijk1, ...
 ~, ...
 tile_ijk1_from_tile_index, ...
 ~, ...
 relative_path_from_tile_index] = ...
    raw_tile_map_from_scopeloc(scopeloc) ;
tile_map_shape_ijk = size(does_exist_from_tile_ijk1) ;

% Now make a lookup table for when the z+1 tile exists, to help with parfor()
does_neighbor_tile_exist_from_tile_index = false(tile_count,1) ;
for tile_index = 1:tile_count ,
    % Does this tile have a z+1 neighbor?
    tile_ijk1 = tile_ijk1_from_tile_index(tile_index,:) ;
    neighbor_tile_ijk1 = tile_ijk1 + [ 0 0 1 ] ;
    if all(neighbor_tile_ijk1 <= tile_map_shape_ijk) ,
        does_neighbor_tile_exist = does_exist_from_tile_ijk1(neighbor_tile_ijk1(1), neighbor_tile_ijk1(2), neighbor_tile_ijk1(3)) ;
    else
        does_neighbor_tile_exist = false ;
    end
    does_neighbor_tile_exist_from_tile_index(tile_index) = does_neighbor_tile_exist ;    
end

%%
tmp=cell(1,tile_count);
parfor tile_index = 1:tile_count ,
    if does_use_new_style_z_match_file_names , 
        match_file_name = sprintf('channel-%d-match-%s.mat', matching_channel_index, direction) ;
    else
        match_file_name = sprintf('match-%s.mat', direction) ;
    end
    % Load the match if the tile has a z+1 neighbor
    if does_neighbor_tile_exist_from_tile_index(tile_index) ,
        relative_path = relative_path_from_tile_index{tile_index} ;
        match_file_path = fullfile(descriptorfolder,relative_path,match_file_name);
        if exist(match_file_path,'file')
            % load descriptors
            tmp{tile_index} = load(match_file_path);
        else
            fprintf('Warning: Missing match file %s\n', match_file_path) ;
        end
    end
end
%%
for tile_index = 1:tile_count
    featmap(tile_index).(genvarname(direction)) = tmp{tile_index};
end

% legacy variable
[neighbors] = buildNeighbor(scopeloc.gridix(:,1:3)); %[id -x -y +x +y -z +z] format
regpts = cell(1,length(featmap));for ii=1:length(regpts);if ~isfield(regpts{ii},'X');regpts{ii}.X=[];regpts{ii}.Y=[];regpts{ii}.matchrate=0;end;end
for ii=1:length(regpts)
    if isempty(featmap(ii).Z);continue;end
    regpts{ii} = featmap(ii).Z.paireddescriptor;
    regpts{ii}.neigs = [ii neighbors(ii,[4 5 7])];
end

