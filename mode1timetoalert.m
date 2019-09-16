function D = mode1timetoalert(D,envelopeOuter,envelopeInner)
%Delete entries with negative Sinkrate - those will never cause a Mode1 Alert
 
rowsToDelete        =any(D.sinkrate_fpm < 964,2);
D(rowsToDelete,:)   =[];

%Initialize arrays
intersectLineX  = zeros(height(D),2);
intersectLineY  = zeros(height(D),2);
D.mode1Outer_s  = nan(height(D),1);
D.mode1Inner_s  = nan(height(D),1);


for idx = 1:height(D)
    
    %Calculate Intersection Points with Polygon for Inner and Outer Envelope
    intersectLineX(idx,:) = [D.sinkrate_fpm(idx) D.sinkrate_fpm(idx)];
    intersectLineY(idx,:) = [D.radioAlt_ft(idx) 0];
    [~,storeD]          = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),...
        envelopeOuter.xVal,envelopeOuter.yVal);
    [~,storeD2]         = polyxpoly(intersectLineX(idx,:),intersectLineY(idx,:),...
        envelopeInner.xVal,envelopeInner.yVal);
    
    % No intersection point found - Sinkrate is too low
    if isempty(storeD)
        continue;
    % Only one intersection point: Point inside Polygon    
    elseif numel(storeD)== 1
        D.mode1Outer_s(idx) = 0;
        continue;
    % Verticals outside the envelope with a sinkrate of 964 FPM will
    % cross an envelope vertex and thus only exhibit one intersection point (but polyxpoly will store two points). Even though the function works correctly 
    else
        yIntersect(1,1) = storeD(1,1);
    end
    
    % Time-to-TAWS is defined by delta in Radio Altitude and Sinkrate
    D.mode1Outer_s(idx) = (D.radioAlt_ft(idx)-yIntersect(1,1))/D.sinkrate_fpm(idx)*60;
    
    % Same Procedure for Inner Curve
    if isempty(storeD2)
        continue;
    elseif numel(storeD) == 1
         D.mode1Outer_s(idx) = 0;
         continue;
    else
        yIntersect(1,1) = storeD2(1,1);
    end
    
    D.mode1Inner_s(idx) = (D.radioAlt_ft(idx) - yIntersect(1,1))/D.sinkrate_fpm(idx)*60;
       
end
end


