% Preprocessing

clear all
close all

load('gdat.mat')
srate = 1525.88;

%eegplot(gdat, 'srate', srate)

%% demean channels
AVG = mean(gdat, 2);
AVGrep = repmat(AVG, 1, size(gdat,2));
gdat = gdat - AVGrep; 

clear AVG AVGrep

%eegplot(gdat, 'srate', srate)



%% exclude channels based on sd?

%% exclude channels

badChannels = [1 2 12 13, 21 33 48 55:64 66 72 85 95 116 127 128]; %41-46 80-93 %save this somehow, for mapping. for example save keepChannels, look at electrode n, find(keepChannels == n), use that index for your data

keepChannels = 1:size(gdat, 1); 
keepChannels(badChannels) = 0; 
keepChannels = keepChannels(keepChannels ~=0); 

gdatNew = gdat(keepChannels,:); 

save('ChannelNo.mat', 'keepChannels'); 
%eegplot(gdatNew, 'srate', srate)

%% Filtering

%gdatFilt=zeros(size(gdatNew));
lowerBound = 0.5;
upperBound = [];
for i=1:size(gdatNew,1) %use as needed per channel
    gdatFilt(i,:)=eegfilt(gdatNew(i,:),srate,lowerBound,upperBound);
end 
%}

%eegplot(gdatFilt, 'srate', srate)

% lowpass filter 200Hz
lowerBound = [];
upperBound = 200;
elecs = 1:size(gdatNew,1); % or 
% elecs = subset
gdatFilt2 = gdatNew; 
for i = elecs %use as needed per channel
    gdatFilt2(i,:)=eegfilt(gdatNew(i,:),srate,lowerBound,upperBound);
end 
%}

eegplot(gdatFilt2, 'srate', srate)

%% Common Average Reference -- replace ECOG.data with whatever your filename
% is, note this has a third dim, namely trials

%% Grouping
manual = 1;
regular = 0; 
% Do manual
if manual
groupvectorALL = [];
groupvector = [];
group(1).elec = [1:64]; 
group(2).elec = [65:128];
%group(i).elec ... etc.
for j = 1:size(group,2);
    groupvectorALL(group(j).elec) = j;
end
groupvector = groupvectorALL(keepChannels);


elseif regular
% Do automatic (if regular intervals) 
% interval
% produce grouping vector
groupvector = [];
interval = 16;
totalelec = 256;
groups = totalelec/interval;
for i = 1:groups;
    groupvector = [groupvector; (i*ones(interval, 1))];
end



else %all in one group
    % make grouping vector
groupvector = [];
totalelec = 256;
groupvector = ones(totalelec, 1);

end

% save the grouping variable, in case you want to redo the analysis
save('groupingvector', group);
%add to data structure after


%% plot power spectrum

sensor = 42;
y = gdatFiltNew(sensor,:);%gdat(99,:); %put in per channel
Fs = srate;                    % Sampling frequency
T = 3/Fs;                     % Sample time
L = length(y);                     % Length of signal
t = (0:L-1)*T;                % Time vector


NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
Sign = 2*abs(Y(1:NFFT/2+1));



% Plot single-sided amplitude spectrum.
figure
plot(f,2*abs(Y(1:NFFT/2+1))) 
title(sprintf('Single-Sided Amplitude Spectrum of sensor %d', keepChannels(sensor)))
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')