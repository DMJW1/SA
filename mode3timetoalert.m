function D = mode3timetoalert(D,envelope3,timeTO)
%If a Sinkrate occurs during TO Phase, the algorithm will not stop
%calculating times before reaching 1500ft 

D.mode3_s = nan(height(D),1);

%Define Intervall (Rows) where Flight is within Take-Off-Mode (Assumption:
%Take-off Mode ends 36s after TO, since ROC Initial Climb B748 is 2500ft/min. Therefore 1500ft reached after 36s)
lowerRadAlt  =  find((D.sinkrate_fpm > 0 & D.time_s < timeTO + 36 & D.radioAlt_ft <= 1500), 1, 'first');


%UpperRadAlt defined by exceeding 1500ft 
upperRadAlt = find(D.radioAlt_ft > 1500, 1, 'first')-1;
descentAlt  = D.radioAlt_ft(lowerRadAlt);

if isempty(descentAlt)
    return;
end


intersectLineX = [0 320];
intersectLineY = [descentAlt descentAlt]; 


[intersectAltLoss,~] = polyxpoly(intersectLineX,intersectLineY,envelope3.xVal,envelope3.yVal);
currAltLoss = 0;

if ~isempty(intersectAltLoss)
    D.mode3_s(lowerRadAlt) = intersectAltLoss(1)/D.sinkrate_fpm(lowerRadAlt)*60;
end

for k = lowerRadAlt+1 : upperRadAlt
    if D.radioAlt_ft(k) > descentAlt
        descentAlt              = D.radioAlt_ft(k);
        intersectLineY          = [descentAlt descentAlt];
        [intersectAltLoss,~]    = polyxpoly(intersectLineX,intersectLineY,envelope3.xVal,envelope3.yVal);
        currAltLoss             = 0;
        if D.sinkrate_fpm(k)>0 && ~isempty(intersectAltLoss)
            D.mode3_s(k)            = (intersectAltLoss(1))/D.sinkrate_fpm(k)*60;
        end
        continue;
    end
    
    % Altitude loss is defined by delta between actual baro alt and
    % previous baro alt
    currAltLoss = currAltLoss + D.baroHeight_ft(k-1) - D.baroHeight_ft(k);
    %currAltLoss = currAltLoss + D.sinkrate_fpm(k-1)*((D.time_s(k)-D.time_s(k-1))/60);
    if intersectAltLoss(1) < currAltLoss
        D.mode3_s(k) = 0;
    else
        D.mode3_s(k) = (intersectAltLoss(1) - currAltLoss)/D.sinkrate_fpm(k)*60;
    end
    
end

D.mode3_s(D.mode3_s<0) = NaN;

end




   


   
   
   



