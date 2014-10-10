% Script to combine single channels into one file
% By Yvonne Fonken

clear all
close all

num_electrodes = 128; % insert total number of electrodes here

filename1 = 'gdat_aEEG_';
filename2 = 'gdat_bEEG_';

% for loop to load each channel and save it into one matrix

for i = 1:num_electrodes
    
    if i < 129
        tmp1 = load([filename1 sprintf('%i.mat', i)], 'gdat*');
        
        
    else
        tmp1 = load([filename2 sprintf('%i.mat', i)], 'gdat*');
    end
    tmp = getfield(tmp1, char(fieldnames(tmp1)));
    gdat(i,:) = tmp;
    
    clear tmp tmp1
    
end

save('gdat.mat', 'gdat')
