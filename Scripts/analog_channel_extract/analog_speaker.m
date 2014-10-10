%This is a script for extracting stimulus timing
clear all
close all

%% Look at the auditory stimulus events
load('speaker1.mat');
analog_spkr = spkr;
clear spkr;
srate = 24414.14;
thresh = 0.3;

spkr = find_aud_evs(analog_spkr,thresh,srate/3,300);

%% Extract the auditory event onsets and offsets, add to behavioral trials
%Load the behavioral data
load('logST40.mat');
logST40 = log;

%Get auditory onset, offsets

toneInd = 1:2:size(spkr, 1);
log.tone = spkr(toneInd, :);

phonemeInd = 2:2:size(spkr, 1);
log.phoneme = spkr(phonemeInd, :);

save('logfile.mat', 'log');

%%


