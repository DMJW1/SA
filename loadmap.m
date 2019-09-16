% loads actual map and the corresponding reference object
function [map,reference] = loadmap(path)
[map,reference] = geotiffread(path);
end
