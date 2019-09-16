addpath 'Testflights'
files = dir('Testflights\*.mat');

Incident=struct('FlightName',[],'AlertTimes',[]);
for i=1:length(files)
    QAR = load(files(i).name);
    QAR=QAR.QAR;
    Incident(i).FlightName=files(i).name;
    if nansum(QAR.gpws_alert)~=0 
        Incident(i).AlertTimes=QAR.time_s(QAR.gpws_alert==1 & QAR.h_ralt1_m>=0 &...
            QAR.h_ralt2_m>=0 & QAR.h_ralt3_m>=0);
    end
end

    
    
    
    
    
    
    
    
    
    
    
    
    