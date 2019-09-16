function [lat_ft2deg,lon_ft2deg] = ft2deg(lat)
%Assume earth ellipsoid as sphere with radius  
r_e = distdim(6356766,'m','ft');

%Conversion Factor 
lat_ft2deg  = (360/(2*r_e*pi));
lon_ft2deg  = (360/(2*sin(deg2rad(90-lat))*r_e*pi));

end

