function nBursts = findBursts(EMG)
%FINDBURSTS analyze the emg signal to detect muscle activity
%   N = FINDBURSTS() analyses the EMG activity to detect burst. Returns
%   the number of bursts found.
%
%   See also GETBURSTS, EXTRACTFEATURES, PLOTBURSTS

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

SAMPLEDUR = round(EMG.sRate*0.05);    % samples for ~.05 sec

m = mean(EMG.sig);
for cc = 3:-1:1
   cent(:,cc) = EMG.sig(:,cc) - m(cc);  % zero mean sig
end
% lowpass
EMG.low = filter(EMG.nLow, EMG.dLow, ...
    abs( cent ) );
ls = size(EMG.low, 1);

head = [];
tail = [];
ch = [];

% intCh = cumsum(EMG.low);
% inflating the initial chunk, which leads to false positives due to
% low-pass filtering
intCh = cumsum([ 3*EMG.low(1:10,:); EMG.low(11:end,:) ]);
intEmg = max(intCh,[],2);

MINVAL = 5;

ii = 15;
while(ii < ls)
    
%     if( any( EMG.low(ii,:) > MINVAL) & ...    % signal has to be at least MINVAL
%             (EMG.low(ii,:) >= 1.1*EMG.low(ii-14,:) ) )  % signal increasing
    if( any( EMG.low(ii,:) > MINVAL) & ...    % signal has to be at least MINVAL
            (EMG.low(ii,:) >= 1.2*intEmg(ii)/ii ) )  % signal greather than movin avg
        
        prev = max(ii-100, 1);  % shifting back some samples
        next = ii+4*SAMPLEDUR;  % shift .2 sec
        
        while(next<ls)
            % close checking the signal with most energy
            [~, maxCh] = max(intCh(next,:)-intCh(prev,:));
            
%             closing = .95*intEmg(next)/next; % close using current mov avg value
            closing = .9*(intCh(next-1)-intCh(prev))/(next-prev);   % close when signal < mean burst energy
            if(EMG.low(next, maxCh) >= closing && ...
                    EMG.low(next, maxCh) > MINVAL )
                next = next+10;
            else    % close the burst
                break;
            end
        end
        
        head = [head, prev]; %#ok<AGROW>
        tail = [tail, min(next,ls)]; %#ok<AGROW>
        [~, maxEn] = max( intCh(tail(end),:)-intCh(prev,:) );
        ch = [ch, maxEn]; %#ok<AGROW>
        
        % fast forward. No more bursts for some samples
        ii = next+5*SAMPLEDUR;
        
    end    % no burst opening
    
    ii = ii+1;
    
end

EMG.heads = head;
EMG.tails = tail;
EMG.ch = ch;

nBursts = size(head,2);

end