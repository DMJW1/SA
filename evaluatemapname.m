function [filename,map_name] = evaluatemapname(lat_deg,lon_deg )

%Check if we need to add zeros in front of the expression, depending on
%the length of the number
map_lat = sprintf('%02d',abs(lat_deg));

map_lon = sprintf('%03d',abs(lon_deg));

%North, East
if(lat_deg >= 0 && lon_deg >= 0)
%     foldername = sprintf('ASTGTMV003_N%sE%s',map_lat,map_lon);
    filename = sprintf('ASTGTMV003_N%sE%s_dem.tif',map_lat,map_lon);
    map_name = sprintf('Map_N%sE%s',map_lat,map_lon);
%     ref_name = sprintf('R_N%sE%s',map_lat,map_lon);
end

%Norht, West
if(lat_deg >= 0 && lon_deg < 0)
%     foldername = sprintf('ASTGTMV003_N%sW%s',map_lat,map_lon);
    filename = sprintf('ASTGTMV003_N%sW%s_dem.tif',map_lat,map_lon);
    map_name = sprintf('Map_N%sW%s',map_lat,map_lon);
%     ref_name = sprintf('R_N%sW%s',map_lat,map_lon);
end

%South, West
if(lat_deg < 0 && lon_deg < 0)
%     foldername = sprintf('ASTGTMV003_S%sW%s',map_lat,map_lon);
    filename = sprintf('ASTGTMV003_S%sW%s_dem.tif',map_lat,map_lon);
    map_name = sprintf('Map_S%sW%s',map_lat,map_lon);
%     ref_name = sprintf('R_S%sW%s',map_lat,map_lon);
end

%South, East
if(lat_deg < 0 && lon_deg >= 0)
%     foldername = sprintf('ASTGTMV003_S%sE%s',map_lat,map_lon);
    filename = sprintf('ASTGTMV003_S%sE%s_dem.tif',map_lat,map_lon);
    map_name = sprintf('Map_S%sE%s',map_lat,map_lon);
%     ref_name = sprintf('R_S%sE%s',map_lat,map_lon);
end

end

