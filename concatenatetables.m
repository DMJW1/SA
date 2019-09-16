function FlightData = concatenatetables(varargin)

FlightData=varargin{1};
for k = 2:nargin
    FlightData = outerjoin(FlightData,varargin{k},'Keys',{'time_s','lat_deg','lon_deg','cas_kts'...
    'flpLdg','gearDown','radioAlt_ft','baroHeight_ft','sinkrate_fpm','gs_fps','glideSlopeDev_dots',...
    'locDev_dots','flightPath_rad','track_rad','closureRate_fpm','closureRateSmooth_fpm'},'MergeKeys',true);
end

%Fill missing values which might appear in string columns 
FlightData.catMode2=fillmissing(FlightData.catMode2,'constant',"");
FlightData.catMode4=fillmissing(FlightData.catMode4,'constant',"");
% 
% FlightData.Cat_Mode2 = [];
% FlightData.Cat_Mode4 = [];
end

