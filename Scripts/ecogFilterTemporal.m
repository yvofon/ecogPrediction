function ecog=ecogFilterTemporal(ecog,filterBands,filterOrder)
% ecog=ecogFilterTemporal(ecog,filterBandsHz,filterOrder) Filter ecog time series
%
% PURPOSE:  Filter Ecog time series temporally. Multiple frequency bands
%           are allowed. This allows the user to define high-pass, low pass,
%           band-stop and band pass filters 
%
% INPUT:
% ecog:     
% filterBandsHz: A matrix containing the pairs of lower and upper filter 
%                bands in column 1 and two respectively. These bands are 
%                understood as pass-bands and defined in Hz.
%                The highest filter frequency is half the sampling
%                frequency (Nyquist).
%                The lowest frequncy is 0
%                Low pass filter: A pair with 0 as the first entry
%                High pass filter: A pair with Nyquist Frequency (or higher) as second entry
%                Band pass filter: A pair with the first entry > 0 and the
%                second < Nyquist. Moreover, FIRST entry < SECOND entry.
%                Band stop filter: A pair with the first entry > 0 and the
%                second < Nyquist. Moreover, SECOND entry < FIRST entry.
% filterOrder:   A vector defining the filter order for each band. 
%
% OUTPUT:
% ecog:
% NOTES:         Requires the signal processing toolbox 

% 090108 JR wrote it 
% 090409 JR included bandstop filters
% 090905 JR trial wise filtering included for refernce and eog channels


if nargin<2
    error('Provide at least the ecog bstructure and the filter bands!!!')
end

%Create the filters
% If we have no filter order do this 
if nargin<3 
    filterOrder=ones(size(filterBands,1))*3; % We use third order as a standard
end

%Outer loop over filter coefficients 
nyquistFreq=1000/ecog.sampDur/2; 
for k=1:size(filterBands,1)
    %Check if frequency bands arer correct
    if any(nyquistFreq<filterBands(k,:))
        warning('Upper frequency limit is the Nyquist frequency (half the sampling frequency. I will correct this for you.') 
        if filterBands(k,1)>nyquistFreq;filterBands(k,1)=nyquistFreq;
        elseif filterBands(k,2)>nyquistFreq;filterBands(k,2)=nyquistFreq;
        else error('Ooops! Code has a flaw. Should never get here');
        end
    end
    
    % Make butterworth filter coefficients
    if filterBands(k,1)==0 && filterBands(k,2)>0  %A low pass filter
        [b,a] = butter(filterOrder(k),filterBands(k,2)/nyquistFreq,'low');
    elseif filterBands(k,1)>0 && filterBands(k,2)==nyquistFreq; %A high pass filter
        [b,a] = butter(filterOrder(k),filterBands(k,1)/nyquistFreq,'high');
    elseif all(filterBands(k,:)>0) && all(filterBands(k,:)<nyquistFreq); %A band filter
        if filterBands(k,2)>=filterBands(k,1) %A band pass
            [b,a] = butter(filterOrder(k),filterBands(k,:)/nyquistFreq);
        elseif filterBands(k,1)>filterBands(k,2) %A band stop
            [b,a] = butter(filterOrder(k),filterBands(k,2:-1:1)/nyquistFreq,'stop');
        end
    else 
        warning(['Could not interpret: ' num2str(filterBands(k,:)) ' Skipping this filter!!!'])
        b=[];a=[];
    end
    
    %Trial wise apply the filter
    for m=1:size(ecog.data,3)
        for ch=1:size(ecog.data,1) %save memory with very long trials
            tmp=ecog.data(ch,:,m)'; %filtfilt operates along columns
            ecog.data(ch,:,m)=filtfilt(b,a,tmp)';
        end
        if isfield(ecog,'refChanTS')
            ecog.refChanTS(:,:,m)=filtfilt(b,a,double(ecog.refChanTS(:,:,m)'))';
        end
        if isfield(ecog,'eogChanTS')
            ecog.eogChanTS(:,:,m)=filtfilt(b,a,double(ecog.eogChanTS(:,:,m)'))';
        end        
    end
end