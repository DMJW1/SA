%% CFIT Load Data
clear;clc;close all

%Choose flight and load data
flight   = input('Please choose flight: ','s');
% AC     = input('Please choose Aircraft Type: ','s');
filename = fullfile(pwd,'Testflights',[flight,'.mat']);
FDM_raw  = load(filename);
FDM_raw  = FDM_raw.QAR;

%Determine time of takeoffC
timeTO   = FDM_raw.time_s(find(FDM_raw.AC_onGnd==0,1,'first'));

% Prefilter Flight Data and check validity of data 
FDM = datamodification(FDM_raw,timeTO,flight);

% Mode 4 Settings
tadHighIntegrity    = false;
overflightDetection = true; 
alternateMode4b     = true;

% Terrain Settings 
stepsizeTerrain     = 1;
egpwsTrajStop       = 60;

%% Define Polygon Mode1, Statistics regarding Mode1 
mode1Outer            = Polygon('mode1Outer');
mode1Inner            = Polygon('mode1Inner');
TawsMode1Statistics   = mode1timetoalert(FDM,mode1Outer,mode1Inner);

%%  Define Polygon Mode2a,Statistics regarding Mode2
mode2a  = Polygon('mode2a');
mode2b1 = Polygon('mode2b1');
mode2b2 = Polygon('mode2b2');
TawsMode2Statistics = mode2timetoalert(FDM,mode2a,mode2b1,mode2b2,timeTO);

%% Define Polygon Mode3,Statistics regarding Mode3
mode3 = Polygon('mode3');
TawsMode3Statistics = mode3timetoalert(FDM,mode3,timeTO);

%% Define Polygon Mode4, Statistics regarding Mode4
mode4a_linear           = Polygon('mode4a_linear');
mode4a_const            = Polygon('mode4a_const');
mode4b_linear           = Polygon('mode4b_linear');
mode4b_const            = Polygon('mode4b_const');
TawsMode4Statistics     = mode4timetoalert_draft(FDM,mode4a_linear, mode4a_const, mode4b_linear, mode4b_const,...
   tadHighIntegrity, overflightDetection, alternateMode4b, timeTO);

%% Define Polygon Mode5, Statistics regarding Mode5
mode5Inner              = Polygon('mode5Inner');
mode5Outer              = Polygon('mode5Outer');
TawsMode5Statistics     = mode5timetoalert(FDM,mode5Outer,mode5Inner);

%% Concatenate Tables and Minimum Values
FDMStatistics = concatenatetables(TawsMode1Statistics ,TawsMode2Statistics ,...
    TawsMode3Statistics ,TawsMode4Statistics ,TawsMode5Statistics );

% Determine minimums for each Mode and Flight 
[min_vals, min_idx] = min([FDMStatistics{:,17:18} FDMStatistics{:,20:21} FDMStatistics{:,23:25}]);
 
min_times           = FDMStatistics.time_s(min_idx);

%% Mode1_Advanced_Terrain
mode1Outer                     = Polygon('mode1Outer');
mode1Inner                     = Polygon('mode1Inner');
TawsMode1Terrain               = mode1advtimetoalert(FDM,mode1Outer,mode1Inner,egpwsTrajStop,stepsizeTerrain);
% 
roundedwithoutTerrain           = round(TawsMode1Statistics.mode1Outer_s);
compareResults                  = [roundedwithoutTerrain TawsMode1Terrain.mode1Outer_s];
rowstoDelete                    = any((compareResults > egpwsTrajStop | isnan(compareResults)),2);
compareResults(rowstoDelete,:)  = [];
devcompareResults               = compareResults(:,1) - compareResults(:,2);
histogram(devcompareResults)
[h,p,ci,stats]=ttest(compareResults(:,1),compareResults(:,2),'Alpha',0.05);
% 
% fileID = fopen('timedeviations.txt','w');
% fprintf(fileID,'%3d \n',devcompareResults);