function [] = onlineRecognition(net, varargin)

clc;
close all;
fclose all;

% closing all ports
for ii = instrfind()
    fclose(ii);
end

DBG = 2;
DRAW = 1;   % visual feedback for debugging

ICA = 0;

if (nargin>1)
    for ii = 1:length(varargin)
        switch(varargin{ii})
            case 'ica'
                ICA = 1;
        end
    end
end

% converting to ad-hoc emgnet classificator
if(strcmp(class(net),'network'))
    net = emgnet(net);
end

%---- OPENING BOARD PORT ------------
board = emgboard('COM6');
board.open();
%------------------------------------

% effective sample rate: 235Hz (270 on the datasheet)
[nLow, dLow] = butter(2, 0.017);   % 4/235
[nHigh, dHigh] = butter(2, 0.085, 'high'); % 20/235

a = []; % ICA initial guess

tmpBuffSize = 540; % space for 2 sec of acquisition (eventually resized)
emg = zeros(tmpBuffSize,3);     % preallocating space
emgStart = 1; emgEnd = 0;

if DRAW
    f = figure;
    set(f,'Position', get(f,'Position').*[.75 1 1.5 1]);
    drawnow;
end

try

% acquiring enough data for a meaningfull first recognition
while(emgEnd-emgStart<110)
    out = board.getEmg();
    outLen = size(out,1);
    emg(emgEnd+1:emgEnd+outLen,:) = out-512;
    emgEnd = emgEnd+outLen;
    pause(3/board.sRate);
end

while(1)
    
    % data acquisition
    out = board.getEmg();
    if DBG
        tAcq = toc;
    end
    
    if(isempty(out))
        pause(.001);
        continue;
    end
        
    outLen = size(out,1);
    
    if(outLen == 0)    % you're running too fast, calm down...
        pause(3/board.sRate);
        continue;
    end
    
    % messy way to avoid costly matrix resizing
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
    
    % segmentation
    [heads, tails] = findBurst( filter(nLow, dLow, abs(emg(emgStart:emgEnd,:))) );
    nBursts = length(heads);
    
    if DBG>1
        fprintf('- emgStart %d, emgEnd %d, len %d\n', emgStart, emgEnd, emgEnd-emgStart+1);
    end
    
    if DRAW
        low = max(filter(nLow, dLow, abs(emg(emgStart:emgEnd,:))),[],2); %#ok<UNRCH>
        
        clf(f);
        figure(f);
        subplot(3,2,[1 3 5]);
        if(nBursts==0)
            plot(low);
        else
            plot(1:length(low), low, ...
                heads(1):tails(1), low(heads(1):tails(1)),'r');
            legend('moving average','found burst');
        end
    end
    
    
    if(nBursts == 0)    % nothing here, trash it
        emgStart = emgEnd-100;
    else
        % adjusting indices
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
                    tAn = toc;
                end
                
                if ICA
                    % rebuilding the signal using only most relevant components
                    [s, a] = ica( filter(nHigh, dHigh, emg(heads(bb):tails(bb),:)), a);
                    if DBG
                        tIca = toc;
                    end
                    feat = extractFeatures(s);
                else
                    feat = extractFeatures( filter(nHigh, dHigh, emg(heads(bb):tails(bb),:)) );
                end                
                if DBG
                    tEx = toc;
                end
                
                nnRes = sim(net, feat);
                if DBG
                    tNN = toc;
                end
                
                resp = find(nnRes>.6);
                fprintf('   %.3f', nnRes);
                fprintf('\n');
                
                if(strcmp(class(board),'dummyboard'))
                    for rr = resp'
                        fprintf('gesture %d (after %.4f s)\n', ...
                            rr, toc-board.gTime);
                    end
                else
                    fprintf('gesture %d\n', resp);
                end
                
                if DBG
                    if ICA
                        fprintf(['time from last acquisition: %.3fs ' ...
                            '(ICA: %.3fs, feats: %.3fs, NN: %.3fs)\n\n'], ...
                            toc-tAcq, tIca-tAn, tEx-tIca, tNN-tEx);
                    else
                        fprintf(['time from last acquisition: %.3fs ' ...
                            '(feats: %.3fs, NN: %.3fs)\n\n'], ...
                            toc-tAcq, tEx-tAn, tNN-tEx);
                    end
                end
                
            else    % if the signal is too short
                if ICA
                    % compunting A (to be used as initguess to speedup
                    % later analysis)
                    tAn = toc;
                    [~, a] = ica( filter(nHigh, dHigh, emg(heads(bb):tails(bb),:)), a);
                    tIca = toc;
                    fprintf('time fastICA only: %.3f\n', tIca-tAn);
                end
                if(DBG)
                    fprintf('... but is so short that isn''t worth analyzing it\n\n');
                end
            end
            
        end
        
        if(emgEnd>tails(end))   % tail < emgEnd => burst is closed, we can flush it
            emgStart = emgEnd-100;
            a = []; % clearing initual guess
            if DBG
                fprintf('burst closed\n\n');
            end
        else    % tail==emgEnd => incomplete burst, keep it
            emgStart = heads(end);
        end
    end
    
    if DRAW     % drawing recognized signals
        
        figure(f);
        for cc = [1,2,3]
            subplot(3,2,2*cc); hold on;
            plot(1:tmpBuffSize, emg(:,cc), ...
                emgStart:emgEnd, emg(emgStart:emgEnd,cc),'r');
            ax = axis;
            plot([emgEnd,emgEnd],ax([3,4]),'g');
            ylabel(sprintf('Ch%d',cc));
        end
        drawnow;
        %         pause();
    end
    
end


catch e
    keyboard;
end



end