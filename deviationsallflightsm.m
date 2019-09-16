%% CFIT Load Data
clear;clc;
%close all

files = dir('Testflights\*.mat');
stepsizeTerrain     = 1;
egpwsTrajStop       = 60;

%timedeviations = cell(size(files,1),1);
%tteststatistic = nan(100,1);
avg_each_flight = nan(100,1);
% comparisonperflight = cell(size(files,1),1);
% fileID = fopen('timedeviations.txt','w');
% fileID = fopen('time_With_Without.txt','w');

for idx=1:length(files)
    
    flight=files(idx).name;
    filename = fullfile(pwd,'Testflights',flight);
    FDM_raw  = load(filename);
    FDM_raw  = FDM_raw.QAR;
    
    timeTO   = FDM_raw.time_s(find(FDM_raw.AC_onGnd==0,1,'first'));
    
    % Prefilter Flight Data depending on Mode Settingpl
    FDM = datamodification(FDM_raw,timeTO,flight);
    %% Define Polygon Mode1, Statistics regarding Mode1
    mode1Outer            = Polygon('mode1Outer');
    mode1Inner            = Polygon('mode1Inner');
    TawsMode1Statistics   = mode1timetoalert(FDM,mode1Outer,mode1Inner);
    
    
    %% Mode1_Advanced_Terrain
    mode1Outer                     = Polygon('mode1Outer');
    mode1Inner                     = Polygon('mode1Inner');
    TawsMode1Terrain               = mode1advtimetoalert(FDM,mode1Outer,mode1Inner,egpwsTrajStop,stepsizeTerrain);
    
    roundedwithoutTerrain           = round(TawsMode1Statistics.mode1Outer_s);
    compareResults                  = [roundedwithoutTerrain TawsMode1Terrain.mode1Outer_s];
    rowstoDelete                    = any((compareResults > egpwsTrajStop | isnan(compareResults)),2);
    compareResults(rowstoDelete,:)  = [];
    devcompareResults               = compareResults(:,1) - compareResults(:,2);
    
    avg_each_flight(idx)= mean(devcompareResults);
    
  % timedeviations{idx} = devcompareResults;
%     comparisonperflight{idx} = compareResults;
    
    
    
    
    %     fprintf(fileID,'%3d \n',devcompareResults);
%     fprintf(fileID,'%d %d \n',compareResults');
end

% listcomparison = cell2mat(comparisonperflight);

%listtimedeviations = cell2mat(timedeviations);
% fclose(fileID);