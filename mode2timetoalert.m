function D = mode2timetoalert(D,envelope2a,envelope2b1,envelope2b2,timeTO)
% Rows with negative ClosureRates are deleted
rowsToDelete        = any(D.closureRateSmooth_fpm<0,2);
D(rowsToDelete,:)   = [];

% Initialize arrays
intersectLineX  = zeros(height(D),2);
intersectLineY  = zeros(height(D),2);
D.catMode2      = strings(height(D),1);
D.mode2_s       = nan(height(D),1);


for i = 1:height(D)
    % Define Upper Limit of the Envelope that changes with CAS
    upperLimitCAS       = min(1650+8.9*(max(D.cas_kts(i),220)-220),2450);
    intersectLineX(i,:) = [D.closureRateSmooth_fpm(i) D.closureRateSmooth_fpm(i)];
    intersectLineY(i,:) = [D.radioAlt_ft(i) 0];
    
    % For each data point a different Upper Limit might be applicable
    envelope2a.yVal(3:4) = upperLimitCAS;
    
    % Product Specification EGPWS provides formula to calculate xValues
    envelope2a.xVal(3)   = (envelope2a.yVal(3)-522)/0.1968;
    
    %Mode 2b2 selected when LS or GS deviation is less than 2 dots. Also
    %selected for 60 seconds after TO. Mode2b2 is more sensitive than 2b1
    %and therefore first entry in the if condition 
    if (abs(D.glideSlopeDev_dots(i))<2 && abs(D.locDev_dots(i))<2) || (D.time_s(i)<timeTO+60 && D.time_s(i)>timeTO)
        [~,storeD] = polyxpoly(intersectLineX(i,:),intersectLineY(i,:),envelope2b2.xVal,envelope2b2.yVal);
        mode = 'Mode2b2';
    % Flaps in Landing Configuration 
    elseif D.flpLdg(i)
        [~,storeD] = polyxpoly(intersectLineX(i,:),intersectLineY(i,:),envelope2b1.xVal,envelope2b1.yVal);
        mode = 'Mode2b1';
    % All other cases Mode2a is active
    else
        [~,storeD] = polyxpoly(intersectLineX(i,:),intersectLineY(i,:),envelope2a.xVal,envelope2a.yVal);
        mode = 'Mode2a';
    end
    
    D.catMode2(i) = mode;
    
    if isempty(storeD)
        continue;
    elseif numel(storeD) == 1
        D.mode2_s(i) = 0;
        continue;
    else
        yIntersect = storeD(1,1);
    end
    
    % Time-to-TAWS Alert defined by delta Radio altitude and actual ClosureRate
    D.mode2_s(i) = (D.radioAlt_ft(i) - yIntersect)/D.closureRateSmooth_fpm(i)*60;

end



