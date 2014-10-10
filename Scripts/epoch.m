% Combine logfile info with data, segment

clear all
close all

analogSrate = 24414.14; 
eegSrate = 1525.88; 
BadTimestamps = [19 20; 23 27; 33 35; 72 74; 116 119; 126 127; 150 151; 276 279; 302 309; 322 324; 483 484; 488 490; 536 542; 671 673; 760 761]; % in seconds
BadTimestamps = BadTimestamps * eegSrate; 

% load logfile
load('logfile.mat')

% load data
load('gdatClean.mat')

% Load channel correspondence
load('ChannelNo.mat')

% ratio between srates
ratio = analogSrate/eegSrate; 

% re-align timestamps obtained from analog channels to 
if ratio ~= 1;  
    log.tone = floor(log.tone/ratio); 
    log.phoneme = floor(log.phoneme/ratio);
end

% initialize datastructure: 
ECOG.log = log; 
%ECOG.data = []; 
ECOG.badTrials = zeros(size(log.tone, 1),1); 
ECOG.srate = eegSrate; 
ECOG.channelNo = keepChannels; %make sure to load C

time = [-1000 3000]; % in ms
timewin = floor(0.001*time*eegSrate);  
%make ECOG.time

% loop through events
for i = 1:size(log.tone, 1)
    % select timepoints
    tmpInd = [(log.tone(i,1)+ timewin(1)):(log.tone(i,1) + timewin(2))];
    
    % store epoch into data structure
   ECOG.data(:,:,i) = gdatClean(:, tmpInd);
   
   % check if bad trial
   for j = 1:size(BadTimestamps,1)
   
       if any(tmpInd > BadTimestamps(j, 1) & tmpInd < BadTimestamps(j, 2))
           ECOG.badTrials(i) = 1;
       end
   end
   clear tmpInd
end

clear i j

%save('data.mat', 'ECOG')

%% do timefrequency analysis

% get centerfrequencies
% blunt force, look into log spacing later
%f = 2:200;
% M: include indCorrect, so that indCongruent etc don't have errors in them
% use ECOG.log.responseCorr. 
indGoodtrials = find(ECOG.badTrials == 0);
% congruent
indCongruent = intersect(find(strcmp(ECOG.log.Type, 'congruent')), indGoodtrials);
indIncongruent = intersect(find(strcmp(ECOG.log.Type, 'incongruent')), indGoodtrials);
indChance = intersect(find(strcmp(ECOG.log.Type, 'chance')), indGoodtrials);

% M: look into what this is doing, play around with different methods
% (morlet, multitaper or hilbert)

% loop over electrodes, or select one electrode
for j = 1: size(ECOG.data,1)
%loop over trials
               
% M: maybe make if statement with 'method'
%take every single included trial
            % skip badtrials, or fill up with zeros to prevent bad trials
            % data to enter averages
            ECOG.sampDur = 1;
            ECOG.timebase = 0:size(ECOG.data,2); % why did this work with timebase = 0:3000?
            f = create_freqs(2,200);
            Ecog = ECOG;
            Ecog.data = ECOG.data(j,:, :);
            ecog = ecogMkSpectrogramMorlet(Ecog, f); % This function comes from yfonken/DATA_ECOG/ecog-scripts
            WAVEL= squeeze(ecog.spectrogram.spectrogram);
            POW=abs(WAVEL).^2; % compute the power (modulus of the complex number given byt the wavelet, squared)
            % Reshape POW to make it the same as with the other methods.
            % POW is time x trials x freq, reshape to freq x time x trials
            for i=1:size(ECOG.data, 3) 
                temp = squeeze(POW(:,i,:))';
                MATPOW(:,:,i)=temp; %we get freq by time by trials matrix
            end
            
            if j == 15
                SiTrData = MATPOW;
            end
            
                %Loop through frequencies
               % for freq = 2:length(f)
                    
                    %WAVEL=my_hilbert(ECOG.data(j,:,i), ECOG.srate, f(freq-1), f(freq),1, 'flatgauss');
                    %POW=abs(WAVEL).^2; % compute the power (modulus of the complex number given byt the wavelet, squared)
                    %MATPOW(freq,:,i)=POW; %we get freq by time by trials matrix
                    %end
                    AVG(1).data(j,:,:)  = mean(MATPOW(:,:,indCongruent), 3)';
                    AVG(2).data(j,:,:) = mean(MATPOW(:,:,indIncongruent),3)';
                    AVG(3).data(j,:,:) = mean(MATPOW(:,:,indChance),3)';
                    AVG(4).data(j,:,:) = mean(MATPOW(:,:,unique([indCongruent; indIncongruent])),3)';
                    
                    % baseline
                    for k = 1:4
                        base = mean(AVG(k).data(j,1000:1400,:),2);
                        base = repmat(base, 1, size(AVG(k).data(j,:,:), 2));
                        AVG(k).dataBL(j,:,:) = (AVG(k).data(j,:,:) - base)./base;
                    end
                    
end




%% plot average timefreq spectrum, one electrode first, multiple later

% select condition, average
% response.rt is not working
%indCorrect = find(ECOG.log.responseCorr);



time = (timewin(1):timewin(2))/ECOG.srate; % M: replace this with ECOG.time
ind = 1000:5000; % only show data that's interesting 
% plot (use imagesc or surf)
% M: Rethink plotting (include original electrode number in plot title, using
% ECOG.channelNo)
figure;
count = 1; 
k = 1; %1 for congruent only, 2 for incongruent, 3 for chance

for elec = 1:40 %indices
   subplot(4,10, count); surf(time(ind),f,squeeze(AVG(k).dataBL(elec, ind, :))');shading interp;view([0 90]);caxis([-1.80 1.80]);set(gca,'YScale','log','YLim',[3 200],'YTick',[3 10 50 100 200]);
        
        % M: what's happening with the axes?
        %subplot(4,10,count); imagesc(time(ind), f, squeeze(AVG(k).dataBL(elec,ind,:))', [-1.5 1.5]); shading interp
        %clim([-0.8 0.8])
        set(gca, 'YDir', 'normal')
       title(sprintf('Electrode %i', ECOG.channelNo(elec)))
        
        count = count+1; 
    
    
end

sensor = 19; 
elec = find(ECOG.channelNo == sensor); 
%%surf((timewin(1):timewin(2))/ECOG.srate, f(2:199), dataCongruent(2:199,:)); shading interp
%elec = 15;
%elec = 15
figure; 
for k = 1:4
    
    
    
    subplot(1,4, k); imagesc(time(ind), f, squeeze(AVG(k).dataBL(elec,ind,:))', [-1.5 1.5]); shading interp
    set(gca, 'YDir', 'normal')
    
end
freqInd = 7:12;
ind = 1200:4000; 
figure; plot(time(ind), squeeze(mean(AVG(4).dataBL(elec,ind,freqInd),3)), 'b');
hold on
plot(time(ind), squeeze(mean(AVG(3).dataBL(elec,ind,freqInd),3)), 'r');

%{
% erpimage? 
figure; 
Titlen = 'Electrode 19'; 
D = squeeze(mean(SiTrData(freqInd,:,[indCongruent; indIncongruent]),1)); 
Tl = [];

erpimage(D, Tl, [1000*time(ind(1)) length(ind) eegSrate], Titlen, 1, 1, 'caxis', [-20 20]);
%}