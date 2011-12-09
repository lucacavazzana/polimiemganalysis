function [] = onlineRec(net)

DBG = 1;
DRAW = 1;

global DATA;
DATA = [];

if DRAW
    f = figure;
    f2 = figure;
    drawnow;
end

[nLow, dLow] = butter(2, 0.0148);   % 4/270
[nHigh, dHigh] = butter(2, 0.0741, 'high'); % 20/270

tmpBuffSize = 540; % space for 2 sec of acquisition
emg = zeros(tmpBuffSize,3);
emgStart = 1; emgEnd = 0;

while(emgEnd-emgStart<110)
    out = symBoard();
    outLen = size(out,1);
    emg(emgEnd+1:emgEnd+outLen,:) = out-512;
    emgEnd = emgEnd+outLen;
end

while(1)
    
    % data acquisition
    out = symBoard();
    outLen = size(out,1);
    
    newEnd = emgEnd+outLen;
    if(newEnd <= tmpBuffSize)
        emg(emgEnd+1:newEnd,:) = out-512;
    else
        newEnd = newEnd-emgStart+1;
        emg(1:newEnd,:) = [emg(emgStart:emgEnd,:); out-512];
        emgStart = 1;
        if(newEnd > tmpBuffSize)
            warning('Warning: resizing emg buffer');
            tmpBuffSize = newEnd;
        end
    end
    emgEnd = newEnd;
    
    fprintf('- emgStart %d, emgEnd %d\n', emgStart, emgEnd);
    
	[heads, tails] = findBurst( filter(nLow, dLow, abs(emg(emgStart:emgEnd,:))) );
    
    if DRAW
        figure(f2);
        clf;
        asd = filter(nLow, dLow, abs(emg(emgStart:emgEnd,:)));
        plot(asd(:,1));
    end
    nBursts = length(heads)
    
    if(nBursts == 0)
        emgStart = emgEnd-100;
    else
        heads = heads + emgStart-1;
        tails = tails + emgStart-1;
        
        if DBG
            disp('got burst at');
            disp(heads);
        end
        
        for bb = 1:nBursts
%             feats{bb}{1} = extractFeatures(emg(heads(bb):tails(bb),:));
        end
        
        if(emgEnd>tails(end))
            emgStart = emgEnd-100;
        else
            emgStart = heads(end);
        end
    end
    
    if DRAW
        figure(f)
        clf;
        subplot(3,1,1);
        plot(1:tmpBuffSize, emg(:,1), ...
            emgStart:emgEnd, emg(emgStart:emgEnd,1),'r');
        subplot(3,1,2);
        plot(emg(:,2));
        subplot(3,1,3);
        plot(emg(:,3));
        pause();
    end
    
end

end