function [dataFiltered] = datamodification(FDM_raw,timeTO,flight)
%% Define required variables
time_s              = FDM_raw.time_s;

sinkrate_fpm        = convvel(-FDM_raw.h_dot_mDs,'m/s','ft/min'); %%positive values imply descending motion

radioAlt_ft         = distdim(FDM_raw.h_ralt2_m,'m','ft');

lon_deg             = rad2deg(FDM_raw.lon_rad);

lat_deg             = rad2deg(FDM_raw.lat_rad);

cas_kts             = convvel(FDM_raw.CAS_mDs,'m/s','kts');

flpLdg              = FDM_raw.FLP_handle_pos>29;

baroHeight_ft       = distdim(FDM_raw.h_baro_m,'m','ft');

glideSlopeDev_dots  = FDM_raw.GS_DEV_2_ddm./0.0875;

locDev_dots         = FDM_raw.LLZ_DEV_2_ddm/0.0875;

gearDown            = FDM_raw.LDG_c1_downLocked;

gs_fps              = convvel(FDM_raw.GS_mDs,'m/s','ft/s');

%Since different aircraft types are equipped with different Radio
%Altimeter and thus Radio Altimeter Limits, an assumption has to be made. When a certain value of RadAlt
%is exceeded, the maximum attainable value is stored (747-8~5500ft). A
%safety margin of 10% is applied
maxRadAlt           = max(radioAlt_ft)*0.9;

%Since all the other variables exhibit a sample rate of at least 1hz,
%values for gamma_rad and psi_trk_rad are linearly interpolated since their sample time is
%only 0.5Hz
FDM_raw.gamma_rad(isnan(FDM_raw.gamma_rad)) = interp1(find(~isnan(FDM_raw.gamma_rad)),...
    FDM_raw.gamma_rad(~isnan(FDM_raw.gamma_rad)), find(isnan(FDM_raw.gamma_rad)), 'linear');
flightPath_rad=FDM_raw.gamma_rad;

FDM_raw.psi_trk_rad(isnan(FDM_raw.psi_trk_rad)) = interp1(find(~isnan(FDM_raw.psi_trk_rad)),...
    FDM_raw.psi_trk_rad(~isnan(FDM_raw.psi_trk_rad)), find(isnan(FDM_raw.psi_trk_rad)), 'linear');
track_rad=FDM_raw.psi_trk_rad;

%% Create Filtered Dataset


dataRaw=table(time_s,lat_deg,lon_deg,cas_kts,flpLdg,gearDown,radioAlt_ft,baroHeight_ft,sinkrate_fpm,gs_fps,...
    glideSlopeDev_dots,locDev_dots,flightPath_rad,track_rad);
        
dataFiltered = rmmissing(dataRaw);
        
%Calculate Closure Rate
%Closure Rate at point i is difference in RadioAlt at point i -
%Radio Alt at point i-1---divided by the time interval
dataFiltered.closureRate_fpm = -[0;diff(dataFiltered.radioAlt_ft)./diff(dataFiltered.time_s)].*60;
%End Closure Rate

% Flight states below 10ft radio altitude, above 90% of the maximum recorded altitude, and time_s < timeTo were not considered in the analysis         
rowsToDelete = any((dataFiltered.time_s <= timeTO | dataFiltered.radioAlt_ft>maxRadAlt | dataFiltered.radioAlt_ft < 10),2);
dataFiltered(rowsToDelete,:) = [];
dataFiltered.closureRateSmooth_fpm = movmean(dataFiltered.closureRate_fpm,[10 0],'Endpoints', 'shrink');

%% Check validity of data 
lat_check   = abs(dataFiltered.lat_deg) > 90;
lon_check   = abs(dataFiltered.lon_deg) > 180;
cas_check   = dataFiltered.cas_kts < 100;

if any(lat_check == 1 | lon_check ==1 | cas_check == 1)
    testvalidity = all([lat_check lon_check cas_check] == 0,2);
    dataFiltered = dataFiltered(testvalidity,:);
    warning(['Please doublecheck data validity of ',flight,'. Invalid flight state deleted.'])
end

end

        
    
 


