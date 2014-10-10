
cd(ANdir);
%% automatically find speaker channel events
fprintf('Running analog gui on speaker channel... \n \n')
spkr = find_aud_evs(analog_spkr,0.6,ANsrate/3,300); %find_aud_evs takes 
%%make sure number of spkr events is correct (whos spkr after running part
for j = 1:length(find(spkr(:,1)))
    spkrEvents(j).event = ['spkr_' num2str(j)];
    spkrEvents(j).onset = spkr(j,1);
    spkrEvents(j).offset = spkr(j,2);
    spkrEvents(j).badevent = 0;
    spkrEvents(j).resp = [];
end

%% go through and check spkrEvents, mark any bad ones.
figsize = [9 49 784 768];
analog_gui(spkrEvents,analog_spkr,ANsrate, figsize)
%% save temp file after closing GUI
save ([ANdir  dlm 'spkrEvents.mat'], 'spkrEvents');
%% automatically find speaker channel events
spkr = find_aud_evs(analog_spkr,0.6,ANsrate/3,300); 

%%make sure number of spkr events is correct 
for j = 1:length(find(spkr(:,1)))
    spkrEvents(j).event = ['spkr_' num2str(j)];
    spkrEvents(j).onset = spkr(j,1);
    spkrEvents(j).offset = spkr(j,2);
    spkrEvents(j).badevent = 0;
    %spkrEvents(j).resp = [];
end

%% go through and check spkrEvents, mark any bad ones.
figsize = [9 49 784 768];
analog_gui(spkrEvents,analog_spkr,ANsrate, figsize)

%% remember to save temp file after closing GUI


%% photodiode (make sure EEGlab is in your path)
pdevents = find_events(pd,ANsrate,1000,500,2,'show') 
clear EEG
for i = 1:length(micEvents)
    EEG.events(i).latency = micEvents(i).onset;
    EEG.events(i).type = micEvents(i).event;
end
eegplot([mic; pd], 'srate', ANsrate, 'events', EEG.events)

