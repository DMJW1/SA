%Hallo
classdef Polygon < handle
%Überprüfung handle TODO    
%User Validierung z.b. Objekt Test nicht möglich
%Überprüfung wie rum polygon erstellt wird
%validierung wo Benutzer was eingeben kann
    properties %(SetAccess = protected)
        mode;
        xVal;
        yVal;
    end
    
    methods
        function obj = Polygon(mode)
            
            ILS_Slope   = deg2rad(3);
            DotRad      = deg2rad(0.36);
            
            switch mode
                case 'mode1Outer'
                    obj.mode = 'mode1Outer';
                    obj.xVal = [964 5007 10000 10000 964];
                    obj.yVal = [10 2450 2450 10 10];
                case 'mode1Inner'
                    obj.mode = 'mode1Inner';
                    obj.xVal = [1482 1710 7125 10000 10000 1482];
                    obj.yVal = [10 284 2450 2450 10 10];
                case 'mode2a'
                    obj.mode = 'mode2a';
                    obj.xVal = [2083 3545 9800 13000 13000 2083];
                    obj.yVal = [30 1220 2450 2450 30 30];
                case 'mode2b1'
                    obj.mode = 'mode2b1';
                    obj.xVal = [2253 3000 10000 10000 2253];
                    obj.yVal = [200 789 789 200 200];
                case 'mode2b2'
                    obj.mode = 'mode2b2';
                    obj.xVal = [2038 3000 10000 10000 2038];
                    obj.yVal = [30 789 789 30 30];
                case 'mode3'
                    obj.mode = 'mode3';
                    obj.xVal = [8 143 320 320 8];
                    obj.yVal = [30 1500 1500 30 30];
                case 'mode4a_linear'
                    obj.mode = 'mode4a_linear';
                    obj.xVal = [0 190 250 400 400 0];
                    obj.yVal = [500 500 1000 1000 30 30];
                case 'mode4a_const'
                    obj.mode = 'mode4a_const';
                    obj.xVal = [0 0 400 400 0];
                    obj.yVal = [30 500 500 30 30];
                case 'mode4b_linear'
                    obj.mode = 'mode4b_linear';
                    obj.xVal = [0 0 185 250 400 400 0];
                    obj.yVal = [30 245 2445 1000 1000 30 30];
                case 'mode4b_const'
                    obj.mode = 'mode4b_const';
                    obj.xVal = [0 0 400 400 0];
                    obj.yVal = [30 245 245 30 30];
%                 case 'mode4a'
%                     obj.mode = 'mode4aFlapsUp';
%                     obj.xVal = [0 190 250 400 400 0];
%                     obj.yVal = [500 500 1000 1000 30 30];
%                 case 'mode4bGearUpFlapsDown'
%                     obj.mode = 'mode4bGearUpFlapsDown';
%                     obj.xVal = [0 0 400 400 0];
%                     obj.yVal = [30 245 245 30 30];
%                 case 'mode4bGearDownFlapsUp'
%                     % Special case for 747-8: 185 kts for mode4B Static
%                     % Envelope
%                     obj.mode = 'mode4bGearDownFlapsUp';
%                     obj.xVal = [0 185 250 400 400 0];
%                     obj.yVal = [245 245 1000 1000 30 30];
                case 'mode5Outer'
                    %between 150ft and 1000ft the max allowed dot
                    %deflection is 1.3 dots
                    %at 50ft, the max allowed do deflection is 2.7 dots
                    %in between the max allowed deflection is found by
                    %linear conjunction (in accordance with Honeywell
                    %Static Soft Alert Envelope for mode5)
                    LowerLimitX = 50/tan(ILS_Slope-DotRad*2.7);
                    MediumLimitX = 150/tan(ILS_Slope-DotRad*1.3);
                    UpperLimitX = 1000/tan(ILS_Slope-DotRad*1.3);
                    
                    obj.mode = 'mode5Outer';
                    obj.xVal = [LowerLimitX MediumLimitX UpperLimitX UpperLimitX LowerLimitX];
                    obj.yVal = [50 150 1000 50 50];
                    
                case 'mode5Inner'
                    %between 150ft and 300ft the max allowed dot
                    %deflection is 2 dots
                    %at 50ft, the max allowed do deflection is 3.4 dots
                    %in between the max allowed deflection is found by
                    %linear conjunction (in accordance with Honeywell
                    %Static Soft Alert Envelope for mode5)
                    LowerLimitX = 50/tan(ILS_Slope-DotRad*3.4);
                    MediumLimitX = 150/tan(ILS_Slope-DotRad*2);
                    UpperLimitX = 300/tan(ILS_Slope-DotRad*2);
                    
                    obj.mode = 'mode5Inner';
                    obj.xVal = [LowerLimitX MediumLimitX UpperLimitX UpperLimitX LowerLimitX];
                    obj.yVal = [50 150 300 50 50];

            end
            
            if isempty(obj.mode)
                error('No valid object name')
            end
            
        end
    end
end



