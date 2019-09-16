%Calculate terrain at starting positions and the respective assumed
%tangential flight path
function terrainHeight_ft = terrainheight(lat,lon)

%Look up the right maps for the flight therefore we round down to the
%closest integer value towards -inf since the maps are named after their
%southwest-corner
lat_floor_deg       = floor(lat);
lon_floor_deg       = floor(lon);
mapsToEvaluate_raw  = [lat_floor_deg lon_floor_deg];

% Initialize array
terrainHeight_ft    = nan(length(lat),1);

% Remove duplicates
mapsToEvaluate = unique(mapsToEvaluate_raw,'rows'); 
%dbstop in terrainheight at 19 if mapsToEvaluate(2)==-99

path_to_aster   = 'C:\Users\dario\LRZ Sync+Share\CFIT_SA_FSD_DARIO_WALTER\AST_Dario_Walter\';
mapAvailable = true;

for idx = 1:size(mapsToEvaluate,1)
    % Assign the required maps a name that can be found in the corresponding Aster Folder
    [filename,map_name] = evaluatemapname(mapsToEvaluate(idx,1),mapsToEvaluate(idx,2));
%     map_name,ref_name
    path = [path_to_aster filename];
    
    if(~exist(path,'file'))
        warning(['The file ' map_name ' does not exist.']);
        mapAvailable = false;
        disp('Map could not be found')
    end
    
    % program optimization - "memoize" keeps map object in cache 
    if(mapAvailable == true)
        memoizedFcn = memoize(@loadmap);
        [mapElev, refObj] = memoizedFcn(path);
    end
    
    % the algorithm loops through each required map and fills corresponding nan
    % values one after another. For nan values that do not possess a
    % corresponding map, the value is set to 0 (ASTER provides Terrain Data
    % for tiles where at least 0.01% of land area are included)
    if mapAvailable == true
        if idx == 1
            terrainHeight_ft = distdim(ltln2val(mapElev,refObj,lat,lon),'m','ft');
        elseif idx > 1
            toFill                      = isnan(terrainHeight_ft);
            terrainHeight_ft(toFill)    = distdim(ltln2val(mapElev,refObj,lat(toFill),lon(toFill)),'m','ft');
        end
    end
    
    
end

%If the map is available, everything is fine and we read the
%data out of the database ASTER. If we dont't have a map, we
%can assume the point is somewhere in the ocean --> MSL
waterZeroFeet                       = isnan(terrainHeight_ft);
terrainHeight_ft(waterZeroFeet)     = 0;

end





