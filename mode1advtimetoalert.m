function D = mode1advtimetoalert(D,envelopeOuter,envelopeInner,stop,stepsize)
%Since Sinkrates below 964 fpm will never cause a Mode 1 alert, they can be
%excluded from the examination
rowsToDelete        = any(D.sinkrate_fpm < 964,2);
D(rowsToDelete,:)   = [];

%Initialize array
D.mode1Outer_s = nan(height(D),1);
D.mode1Inner_s = nan(height(D),1);

%Speed Vector for egpws trajectory
speedLat_fps       = D.gs_fps.*cos(D.track_rad);
speedLon_fps       = D.gs_fps.*sin(D.track_rad);
speedHeight_fps    = D.sinkrate_fpm./60;
speedVector        = [speedLat_fps speedLon_fps speedHeight_fps];

steps = (0 : stepsize : stop)';

% Loop over all filtered positions and create TAWS trajectory for each
% starting point idx
for idx = 1 : height(D)
    %TAWS Trajectory Starting Points - Choose radAlt instead of baroHeight to
    %get rid of temperature and QNH influence
    startGeoCoord           = [D.lat_deg(idx) D.lon_deg(idx)];
    
    %ft2deg conversion required and only done once in each loop since it
    %does not change much for the trajectory
    [lat_ft2deg,lon_ft2deg] = ft2deg(startGeoCoord(1));
    
    %Define LAtitude and Longitude positions on EGPWS trajectory
    posTrajectoryLat        = startGeoCoord(1) + steps.*lat_ft2deg.*speedVector(idx,1);
    posTrajectoryLon        = startGeoCoord(2) + steps.*lon_ft2deg.*speedVector(idx,2);
    
    % Terrain height for all positions on single flight trajectory
    terrainHeight_ft        = terrainheight(posTrajectoryLat,posTrajectoryLon);
    startAlt                = D.radioAlt_ft(idx) + terrainHeight_ft(1);
    
    % Terrain Clearance defined by True Altitude above terrain (Radio Alt) 
    posTrajectoryAlt_ft     = startAlt - steps.*speedVector(idx,3);
    terrainClearance_ft     = posTrajectoryAlt_ft - terrainHeight_ft;
    
    % Find first extrapolated value which is in polygon. This value
    % provides an integer time to Mode1 Alert
    sinkratePoly(1:length(terrainClearance_ft),1) = D.sinkrate_fpm(idx);
    inPolyOuter = inpolygon(sinkratePoly,terrainClearance_ft,envelopeOuter.xVal,envelopeOuter.yVal);
    inPolyInner = inpolygon(sinkratePoly,terrainClearance_ft,envelopeInner.xVal,envelopeInner.yVal);
    
    %Multiply with step size since an alert event e.g. with stepsize 4 in
    %the 3rd row corresponds to 8s from the initial flightstate: (3-1)*4=8
    if any(inPolyOuter(:) == 1)
        D.mode1Outer_s(idx)  = (find(inPolyOuter == 1,1,'first') - 1)*stepsize ;
    end
    
    if any(inPolyInner(:) == 1)
        D.mode1Inner_s(idx)  = (find(inPolyInner == 1,1,'first') - 1)*stepsize ;
    end
end
end


    %     terrainHeight_ft        = arrayfun(@terrainheight2,posTrajectoryLat,posTrajectoryLon,'UniformOutput',true);
    %     terrainHeight_ft        = terrainheight2(posTrajectoryLat,posTrajectoryLon);
    

