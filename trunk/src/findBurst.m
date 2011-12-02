function [head, tail, ch] = findBurst(emg)
%FINDBURST
%  [HEAD, TAIL, CH] = FINDBURST(EMG) gets (one or more) EMG channel data
%  and

head = [];
tail = [];
ch = [];

SAMPLEDUR = 270;   % 1s acquisition

ls = length(emg);

% inflating the initial chunk, which leads to false positives due to
% low-pass filtering
intCh = cumsum([3*emg(1:50,:);emg(51:end,:)]);
intEmg = max(intCh,[],2);

ii = 2;
while(ii<ls)
    if(any( (emg(ii,:) > 10) & ...    % signal has to be at least 10
            (emg(ii,:) >= 1.22*intEmg(ii)/ii) ))  % signal greather than movin avg
        % e se sostituissi la media mobile con quella globale?
        
        prev = max(ii-100, 1);  % shifting back some samples
        
        next = prev+SAMPLEDUR;
        if(next>ls)
            break;  % not enough data to complete an recognition
        end
        
        % close checking the signal with most energy
        while(next<ls)
            [~, maxEn] = max(intCh(next,:)-intCh(prev,:));
            if(emg(next,maxEn) >= .95*intEmg(next)/next)
                next = next+50;
            else
                break;
            end
        end
        
        head = [head, prev];
        tail = [tail, min(next,ls)];
        ch = [ch, maxEn];
        
        ii = next+100;
        
    else
        
        ii = ii+10;
        
    end
    
end

end