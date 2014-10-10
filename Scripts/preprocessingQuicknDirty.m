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
%{
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

% Do separate re-referencing for depth and ecog electrodes
ind = 1:47; %looked up correspondence manually in keepChannels


AVGcar=mean(gdatFilt2(ind,:),1); %average over all sensors
AVGcarrep=repmat(AVGcar, size(gdatFilt2(ind,:),1),1); %array with average with same size as ECOG.data
gdatCar(ind,:)=gdatFilt2(ind,:)-AVGcarrep;

clear AVGcar AVGcarrep ind

ind = 48:size(gdatFilt2,1); 

AVGcar=mean(gdatFilt2(ind,:),1); %average over all sensors
AVGcarrep=repmat(AVGcar, size(gdatFilt2(ind,:),1),1); %array with average with same size as ECOG.data
gdatCar(ind,:)=gdatFilt2(ind,:)-AVGcarrep;

clear AVGcar AVGcarrep




eegplot(gdatCar, 'srate', srate)

gdatClean = gdatCar; 

save('gdatClean.mat', 'gdatClean')

%% plot power spectrum

sensor = 42;
y = gdatClean(sensor,:);%gdat(99,:); %put in per channel
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