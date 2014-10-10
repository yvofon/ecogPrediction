function auds = find_aud_evs(spkr,thresh,noise_block,min_stim,max_length,num_blocks)
%   auds = find_aud_evs(spkr,thresh,noise_block,min_stim,max_length,num_blocks)
%          finds events in an auditory channel
%          spkr - speaker channel
%          thresh, noise_block, max_length ,num_blocks,min_stim are optional
%          Defaults:
%            thresh = 0.02;              % noise threshold
%            noise_block = 300;         % contiguous noise block large enough to define point of stimulus end
%            min_stim = 100 (samples)
%            max_length = length(spkr);  % maximum stimulus length
%            num_blocks =1;
        if nargin<6,
            num_blocks =1;
        end
        if nargin<5,
            max_length = length(spkr);         % maximum stimulus length
        end
        if nargin<4,
            min_stim =100; % samples
        end
        if nargin <3,
            noise_block = 300;         % contiguous noise block large enough to define point of stimulus end
        end
        if nargin<2,
            thresh = 0.02;              % noise threshold
        end
        if (max_length<=noise_block)
            disp('max_length must be at least noise_block size, changing to noise_block');
            max_length = noise_block+1;
        end
        start = 0;                  % temporary start stimulus point
        finish = 0;                 % temporaty finish stimulus point
        cnt_noise = 0;              % counter for noise block
        i = 1;                      % counter for stimulus number
        st = 1;                     % counter for position within the signal
        auds = zeros(100*num_blocks,2);        % array of 200x2 for stimuli

        while (st < length(spkr))
           if (spkr(st)>thresh || spkr(st)<(-thresh))   % above noise
               if (start == 0)                          % haven't reached stimulus start yet
                   start  = st;
               else
                   finish = st;
               end 
               cnt_noise = 0;
           elseif (start ~= 0)                          % in noise and haven't saved last stimulus
              cnt_noise = cnt_noise+1;
              if (cnt_noise > noise_block)              % contiguous noise block -> save last stimulus
                  if ((st-start)>max_length)        % skip detected stim because it is larger than max_length
                      start = 0; finish = 0;
                  else
                      if (finish -start) >min_stim
                        auds(i,:) = [start finish];
                        i = i+1;
                      end
                      start = 0; finish = 0;
                  end
              end
           end
           st = st+1;
        end
end

