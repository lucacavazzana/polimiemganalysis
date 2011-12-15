function [] = onlineRec(net)

clc;
DBG = 1;
DRAW = 1;   % visual feedback for debugging

fclose all;
global BOARD;    % to reset the symBoard function
BOARD = [];

if DRAW
    close all;
    f = figure;
    set(f,'Position', get(f,'Position').*[.75 1 1.5 1]);
    drawnow;
end

[nLow, dLow] = butter(2, 0.0148);   % 4/270
[nHigh, dHigh] = butter(2, 0.0741, 'high'); % 20/270

chunk = [];

tmpBuffSize = 540; % space for 2 sec of acquisition (eventually resized)
emg = zeros(tmpBuffSize,3);
emgStart = 1; emgEnd = 0;

% acquiring enough data to allow a first recognition
while(emgEnd-emgStart<110)
    [out, chunk] = parseEMG(simBoard2(), chunk);
    outLen = size(out,1);
    emg(emgEnd+1:emgEnd+outLen,:) = out-512;
    emgEnd = emgEnd+outLen;
    pause(.05);
end

while(1)
    
    % data acquisition
    try
        [out, chunk] = parseEMG(simBoard2(), chunk);
    catch e
        warning('NO MORE DATA');
        return;
    end
    
    outLen = size(out,1);
    
    if(outLen==0)
        pause(.05-toc);
        continue;
    end
    
    
    newEnd = emgEnd+outLen;
    if(newEnd <= tmpBuffSize)
        emg(emgEnd+1:newEnd,:) = out-512;
    else
        newEnd = newEnd-emgStart+1;
        emg(1:newEnd,:) = [emg(emgStart:emgEnd,:); out-512];
        emgStart = 1;
        if(newEnd > tmpBuffSize)
            warning('resizing emg buffer');
            tmpBuffSize = newEnd;
        end
    end
    emgEnd = newEnd;
    
    [heads, tails] = findBurst( filter(nLow, dLow, abs(emg(emgStart:emgEnd,:))) );
    nBursts = length(heads);
    
    if DBG
        fprintf('- emgStart %d, emgEnd %d, len %d\n', emgStart, emgEnd, emgEnd-emgStart+1);
    end
    if DRAW
        low = filter(nLow, dLow, abs(emg(emgStart:emgEnd,:)));
        clf;
        subplot(3,2,[1 3 5]);
        if(nBursts==0)
            plot(low(:,1));
        else
            plot(1:length(low), low(:,1), ...
                heads(1):tails(1), low(heads(1):tails(1),1),'r');
            legend('moving average','found burst');
        end
    end
    
    if(nBursts == 0)
        emgStart = emgEnd-100;
    else
        ls = tails-heads+1;
        heads = heads + emgStart-1;
        tails = tails + emgStart-1;
        
        if DBG
            fprintf('got %d burst(s)\n', nBursts);
            fprintf('burst @ %d, length %d \n', heads, ls);
        end
        
        % feature extraction
        for bb = 1:nBursts
            if(ls(bb)>110)  % FIXME: under 110 (tune this) samples the result isn't very relailable
                if DBG
                    t1 = toc;
                end
                feat = extractFeatures( filter(nHigh, dHigh, emg(heads(bb):tails(bb),:)) );
                if DBG
                    t2 = toc;
                end
                nnRes = net(feat);
                resp = find(nnRes>.6);
                fprintf('   %.3f', nnRes);
                fprintf('\n');
                if(~isempty(resp))
                    fprintf('gesture %d\n', resp);
                end
                if DBG
                    t3 = toc;
                    fprintf(['time from last acquisition: %.3fs '...
                        '(feats: %.3fs, NN: %.3fs)\n\n'], t3, t2-t1, t3-t2);
                end
            elseif(DBG)
                fprintf('... but is so short that isn''t worth analyzing it\n\n');
            end
            
        end
        
        if(emgEnd>tails(end))   % tail < emgEnd => burst is closed, we can flush it
            emgStart = emgEnd-100;
        else    % tail==emgEnd => incomplete burst, keep it
            emgStart = heads(end);
        end
    end
    
    if DRAW
        subplot(3,2,2); hold on;
        plot(1:tmpBuffSize, emg(:,1), ...
            emgStart:emgEnd, emg(emgStart:emgEnd,1),'r');
        ax = axis;
        plot([emgEnd,emgEnd],ax([3,4]),'g');
        ylabel('Ch1');
        subplot(3,2,4); hold on;
        plot(1:tmpBuffSize, emg(:,2),  ...
            emgStart:emgEnd, emg(emgStart:emgEnd,2),'r');
        ax = axis;
        plot([emgEnd,emgEnd],ax([3,4]),'g');
        ylabel('Ch2');
        subplot(3,2,6); hold on;
        plot(1:tmpBuffSize, emg(:,3), ...
            emgStart:emgEnd, emg(emgStart:emgEnd,3),'r');
        ax = axis;
        plot([emgEnd,emgEnd],ax([3,4]),'g');
        ylabel('Ch3');
        drawnow;
%         pause();
    end
    
end

end