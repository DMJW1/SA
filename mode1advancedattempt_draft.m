function D = mode1advancedattempt_draft(D,envelopeOuter,stop)
%Since negative Sinkrates will never cause a Mode1 alert, they can be
%excluded from the examination

%Hallo Welt Klappe 2
rowsToDelete        = any(D.sinkrate_fpm <= 0,2);
D(rowsToDelete,:)   = [];

%Initialize array
D.mode1Outer_s = nan(height(D),1);


%Speed Vector for FuturePositions
speedLat_fps       = D.gs_fps.*cos(D.track_rad);
speedLon_fps       = D.gs_fps.*sin(D.track_rad);
speedHeight_fps    = D.sinkrate_fpm./60;
speedVector        = [speedLat_fps speedLon_fps -speedHeight_fps];


for idx = 1:height(D)
    
    %EGPWS Trajectory Starting Points - Choose radAlt instead of baroHeight to
    %get rid of temperature and QNH influence
    startGeoCoord           = [D.lat_deg(idx) D.lon_deg(idx)];
    startHeight             = D.radioAlt_ft(idx) + terrainheight(D.lat_deg(idx),D.lon_deg(idx));
    startPos                = [startGeoCoord startHeight];
    
    %     we track the egpws trajectory to look for egpws alerts
    %     beginning at the startPos
    terrainClearance_ft = D.radioAlt_ft(idx);
    
    if inpolygon(speedHeight_fps(idx)*60,terrainClearance_ft,envelopeOuter.xVal,envelopeOuter.yVal)
        D.mode1Outer_s(k)  = 0;
        continue;
    else
        
        delta_t_s   = 1;
        egpwsPos    = startPos;

        while 1
            egpwsPos = startPos + delta_t_s*ft2deg(egpwsPos).*speedVector(idx,:);
            
            terrainClearance_ft = egpwsPos(3) - terrainheight(egpwsPos(1),egpwsPos(2));
            
            if inpolygon(speedHeight_fps(idx)*60,terrainClearance_ft,envelopeOuter.xVal,envelopeOuter.yVal)
                D.mode1Outer_s(idx)  = delta_t_s;
                break;
            end
            
            if delta_t_s >= stop
                D.mode1Outer_s(idx)  = NaN;
                break;
            end
            
            
            delta_t_s       = delta_t_s+1;
            
        end
        
    end
    
end




end



    
    
    
    
    
    
