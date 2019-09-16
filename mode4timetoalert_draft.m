function D = mode4timetoalert_draft(D,mode4a_linear, mode4a_const, mode4b_linear, mode4b_const,...
   tadHighIntegrity, overflightDetection, alternateMode4b, timeTO)
% Initialize arrays
intersectLineX  = zeros(height(D),2);
intersectLineY  = zeros(height(D),2);
D.catMode4      = strings(height(D),1);
D.mode4_s       = nan(height(D),1);

req4a_linear    = (D.gearDown == 0 & D.flpLdg == 0 & tadHighIntegrity == false);
req4a_const     = (D.gearDown == 0 & D.flpLdg == 0 & tadHighIntegrity == true) |...
    (D.gearDown == 0 & D.flpLdg == 1 & alternateMode4b == false);

req4b_linear    = (D.gearDown == 1 & D.flpLdg == 0 & tadHighIntegrity == false);
req4b_const     = (D.gearDown == 0 & alternateMode4b == true & D.flpLdg == 1) |...
    (D.gearDown == 1 & D.flpLdg == 0 & tadHighIntegrity == true);

%According to Honeywell MKV Manual, 75% of the last 15s have to be averaged (with
%movmean function this implies the actual value plus the previous
%fourteen)for Mode 4C
mode4cMinTerrClear = 0.75.*movmean(D.radioAlt_ft,[14 0],'Endpoints', 'shrink');


%Linear Interpolation to determine required Terrain Clearance for Speeds
%between 190kts and 250kts, 1000ft MTC for Speeds above 250kts , 500ft MTC
%for Speeds below 190kts
maxTerrainClearance = interp1([190 250],[500 1000],D.cas_kts,'linear');
maxTerrainClearance(isnan(maxTerrainClearance)&D.cas_kts<=190) = 500;
maxTerrainClearance(isnan(maxTerrainClearance)&D.cas_kts>=250) = 1000;

%Envelope is different for 747-8 (and currently is only valid for CFX 747-8
%data)
% if AC_Type~='747-8'
%     errordlg('Incorrect Aircraft Type','Type Error')
% end

i = 1;

% Time during TO needs to be specified
while D.time_s(i) <= timeTO+36 && D.radioAlt_ft(i) < 1500
    %See Honeywell Product Specification
    if ~D.gearDown(i) || ~D.flpLdg(i)
        D.catMode4(i) = 'Mode4C';
        if D.closureRateSmooth_fpm(i)>0
            % If a negative value occurs, the value needs to be set to zero
            % --> use maximum 
            D.mode4_s(i) = max((D.radioAlt_ft(i) - max(mode4cMinTerrClear(i),maxTerrainClearance(i)))/D.sinkrate_fpm(i)*60,0);
        end
    end
    i = i+1;
end


for idx = i:height(D)
    
    %Due to barometric altimeter errors the actual separation can be
    %somewhat less than 1000ft
    %Overflight Detection - Upper Limit is reduced to 800ft if ClosureRate >= 2200 ft per
    %second (132000 fpm) is detected. This state remains for the next 60 seconds after excessive Closure Rate
    %was detected
    if overflightDetection == true
        if D.closureRate_fpm(idx) >= 132000
            startOverFlight = D.time_s(idx);
        end
        if exist('startOverflight','var')
            if D.time_s(idx) <= startOverFlight +60
                mode4a_linear.yVal(3:4) = 800;
                mode4b_linear.yVal(3:4) = 800;
            else
                mode4a_linear.yVal(3:4) = 1000;
                mode4b_linear.yVal(3:4) = 1000;
            end
        end
    end
    
    %Maintain Flightpath
    intersectLineX(idx,:) = [D.cas_kts(idx) D.cas_kts(idx)];
    intersectLineY(idx,:) = [D.radioAlt_ft(idx) 0];
    
    
    if req4a_linear(idx) == true
        [~,storeD] = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),mode4a_linear.xVal,mode4a_linear.yVal);
        mode = mode4a_linear.mode;
        
    elseif req4a_const(idx) == true
        [~,storeD] = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),...
            mode4a_const.xVal,mode4a_const.yVal);
        mode = mode4a_const.mode;
        
    elseif req4b_linear(idx) == true
        [~,storeD] = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),mode4b_linear.xVal,...
            mode4b_linear.yVal);
        mode = mode4b_linear.mode;
        
    elseif req4b_const(idx) == true
        [~,storeD] = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),mode4b_const.xVal,...
            mode4b_const.yVal);
        mode = mode4b_const.mode;
    else
        D.catMode4(idx) = 'No Warning';
        continue;
    end
    
    D.catMode4(idx) = mode;
    %Only one crossing - DataPoint inside Envelope
     if isempty(storeD)
        continue;
     elseif numel(storeD) == 1
        D.mode4_s(idx) = 0;
        continue;
    else
        yIntersect = storeD(1,1);
    end
    
    %Calculate Time-to-TAWS: Divide delta RadioAltitude by Barometric
    %Sinkrate
    if  D.sinkrate_fpm(idx)>0
        D.mode4_s(idx) = (D.radioAlt_ft(idx)-yIntersect) / D.sinkrate_fpm(idx)*60;
    end
 
    
    
end
end

