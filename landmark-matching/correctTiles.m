function desc = correctTiles(desc,dims)
% flip 
desc(:,1:2) = dims(1:2)+1 - desc(:,1:2);