function D = mode5timetoalert(D,mode5Outer,mode5Inner)

%All of the following must be true for mode 5 to be active: Valid
%RA(<5000ft), glideslope data valid 
% rowsToDelete = any((D.sinkrate_fpm<0),2);
% D(rowsToDelete,:) = [];

%Standard 3 degree ILS Slope
ilsSlope = deg2rad(3);

% Modern Airlines are equiped with GS Indicator with 2 dots on each side (fly up, fly down). A full
% scale deflection corresponds to 2 dots and 0.72 degree GS deviation.
% Therefore, 1 dot deviation is equal to 0.36 degrees
% For older Aircrafts with CDI the deviation in degrees per dot is 0.14°(not considered)
ilsDeviation_rad = deg2rad(D.glideSlopeDev_dots*0.36);

%Initialize arrays
D.mode5Outer_s = nan(height(D),1);
D.mode5Inner_s = nan(height(D),1);

%Speed along Flight Path
speed = sqrt((D.sinkrate_fpm).^2+(D.gs_fps*60).^2);

%FlightPath Angle
m = D.flightPath_rad;
% m2=atan(D.Sinkrate_fpm./D.GS_fpm);


for i = 1:height(D)
    %dbstop in mode5timetoalert at 31 if i==13188
    f   = @(x)(ilsSlope+ilsDeviation_rad(i))*x;
    g   = @(x) D.radioAlt_ft(i);
    fg  = @(x) f(x)-g(x);
    xCrossing = fzero(fg,5000);
    % Actual Position: 
    % x - Position: Determined by crossing RadAlt and GS deviation
    %,y - Position: Determined by Radio Altitude
    pos = [xCrossing,D.radioAlt_ft(i)];  
    x   = [0 pos(1)];
    y   = -m(i)*(x - pos(1)) + pos(2);
    
    %Determine Intersection Points Flightpath and Mode5Envelope_Outer
    [storeXOuter,storeYOuter] = polyxpoly(x,y,mode5Outer.xVal,mode5Outer.yVal);
    
    %Determine Intersection Points Flightpath and Mode5Envelope_Inner
    [storeXInner,storeYInner] = polyxpoly(x,y,mode5Inner.xVal,mode5Inner.yVal);
    
    % Inside Polygon
    if size(storeXOuter,1) == 1 && size(storeYOuter,1) == 1
        D.mode5Outer_s(i) = 0;
        
    elseif isempty(storeXOuter) && isempty(storeXOuter)
      
    else
        %Determin horizontal and vertical distance between point of
        %intersectio and actual position
        xDistance = xCrossing - max(storeXOuter);
        yDistance = D.radioAlt_ft(i) - max(storeYOuter);
        
        %Determine Time-to-TAWS by calculating remaining Distance to
        %Envelope and subsequently divide it by velocity vector
        distToFly = sqrt(xDistance^2+yDistance^2);
        D.mode5Outer_s(i) = distToFly/speed(i)*60;
    end
    
    
        
    if size(storeXInner,1) == 1 && size(storeYInner,1) == 1
        D.mode5Inner_s(i) = 0;
        continue;
        
    elseif isempty(storeXInner) && isempty(storeYInner)
        continue;
        
    else
        xDistance = xCrossing - max(storeXInner);
        yDistance = D.radioAlt_ft(i) - max(storeYInner);
        
        distToFly = sqrt(xDistance^2+yDistance^2);
        D.mode5Inner_s(i) = distToFly/speed(i)*60;
        
    end
    
    

   
end



% g(x)=(ILS_Slope-D.GlideSlopeDevDots*deg2rad(0.2))*x;

%     syms x
%     g(x)=(ILS_Slope+D.GlideSlopeDevDots(i)*deg2rad(0.2))*x;
%     eqn=g(x)==D.RadioAlt_ft(i);
%     PosX=double(vpasolve(eqn,x));
%     Pos=[PosX,D.RadioAlt_ft(i)];
%     x=[0 Pos(1)];
%     y=m(i)*(x - Pos(1)) + Pos(2);





   