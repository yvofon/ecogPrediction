function event =find_events(data, srate, minITI, minDuration, event_thresh, show)

% events = find_events(data, srate, minITI, minDuration, event_thresh)
%
% returns a structure with onsets and offsets for the input data
% data            vector of data to look into
% srate           sampling rate in Hz
% minITI          minimum ms between offset and the next onset
% minDuration     minimum ms duration for each event. 
% show            'show' or 'none' or just nothing. If 'show' shows the origingal data and 
%                 events using EEGplot. Onset are marked as +5 and offset as -5
% 
%   The output is a structure with fields onsets and offsets. To make the
%   function produce a two column vector instead, umark the line with the
%   comment "% UNMARK THIS FOR AN OUTPUT OF A TWO COLUMN MATRIX"

% Leon Deouell 20/1/2010

%% some checks and housekeeping

if ~isvector(data)
    error('Data must be a vector, not a matrix')
end
if size(data,1)<size(data,2)           %input was a row - we need to trasnpose
    data = data';
end

minITIsamples = minITI*srate/1000;           %convert from ms to samples 
minDurationsamples = minDuration*srate/1000; %convert from ms to samples

%% find the events
over=find(data>event_thresh);  %find samples above threshold
d = diff(over);         %find the gap (in samples) between consecutive over-threshold smaples
event.onsets = [over(1); over(find(d>minITIsamples)+1)];
event.offsets = [ over(find(d>minITIsamples)); over(end)];

if minDuration > 0             %look for events which are too short and eliminate
    event_durations = event.offsets - event.onsets;
    tooshort = find(event_durations < minDurationsamples);
    event.onsets(tooshort) = [];
    event.offsets(tooshort) = [];
end

%event = [event.onsets event.offsets]; % UNMARK THIS FOR AN OUTPUT OF A TWO COLUMN MATRIX
                                       


%% show if requested

% create vectors to show in EEGplot to check

if exist('show','var') && strcmp(show, 'show')

    for i = 1:length(event.onsets)  % create the events structure a la EEGlab
        EEG.events(2*i-1).latency = event.onsets(i);
        EEG.events(2*i-1).type = 'onset';

        EEG.events(2*i).latency = event.offsets(i);
        EEG.events(2*i).type = 'offset';
    end
    eegplot(data','srate', srate,'dispchans',1,'events', EEG.events)
%     eegplot(data','srate',srate,'events',EEG.events,'data2',mic') %overlay
end