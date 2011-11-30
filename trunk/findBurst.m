function [head, tail, ch] = findBurst(emg)

head = [];
tail = [];

SAMPLEDUR = 270;   % 1s acquisition

prev = -1;
next = -1;

ls = length(emg);

intEmg = cumsum([30*emg(1,:);emg(2:end,:)]);

ii = 2;
while(ii<ls)
    if(any( (emg(ii,:) > 10) & ...    % signal has to be at least 10
            (emg(ii,:) >= 1.22*intEmg(ii,:)/ii) ))  % signal greather than movin avg
        % e se sostituissi la media mobile con quella globale?
        
        prev = max(ii-100, 1);  % shifting back some samples
        
        next = prev+SAMPLEDUR;
        if(next>ls)
            break;
        end
        
        while( any(emg(next,:) >= .95*intEmg(next,:)/next) && next<ls)
            next = next+50;
        end
        
        if(next>ls)
            next=ls;
        end
        
        head = [head, prev];
        tail = [tail, next];
        
        ii = next+100;
        
    else
        
        ii = ii+10;
        
    end
    
end

if (nargout == 3)
    ch(1,length(head)) = 0;
    for ii=1:length(head)
        [a ch(ii)] = max(intEmg(tail(ii))-intEmg(head(ii)));
    end
end

end