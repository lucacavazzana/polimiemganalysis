function [] = onlineRecognition(net, varargin)

clc;
DBG = 1;
DRAW = 1;   % visual feedback for debugging
CMPSIM = 0;

ICA = 1;    % still testing

global PORT;  % serial port name

if (nargin>1)
    for ii = 1:length(varargin)
        switch(varargin{ii})
            case 'ica'
                ICA = 1;
        end
    end
end

fclose all;

%---- OPENING PORT ------------------
try     % clear all handlers using our port
    fclose(instrfind({'Port','Status'},{PORT, 'open'}));
catch e %#ok<NASGU>
end
board = serial(PORT, ...
    'BaudRate', 57600, ...
    'InputBufferSize',  4590); % >1 sec of data
fopen(board);
%------------------------------------

% to reset the simBoard function (when dummy board used)
% global BOARD;
% BOARD = [];



if DRAW
    close all; %#ok<UNRCH>
    f = figure;
    set(f,'Position', get(f,'Position').*[.75 1 1.5 1]);
    drawnow;
end

% initializing network struct
net = nn.hints(net);
if net.hint.zeroDelay, nnerr.throw('Network contains a zero-delay loop.'); end
netStr = struct(net);

% effective sample rate: 235Hz (270 on the datasheet)
[nLow, dLow] = butter(2, 0.017);   % 4/235
[nHigh, dHigh] = butter(2, 0.085, 'high'); % 20/235

chunk = []; % tmp buffer for parsing
a = []; % ICA initial guess

tmpBuffSize = 540; % space for 2 sec of acquisition (eventually resized)
emg = zeros(tmpBuffSize,3);
emgStart = 1; emgEnd = 0;

% acquiring enough data to allow a first recognition
while(emgEnd-emgStart<110)
    [out, chunk] = parseEMG(fscanf(board, '%c', board.BytesAvailable), chunk); tic;
%     [out, chunk] = parseEMG(simBoard(), chunk);
    outLen = size(out,1);
    emg(emgEnd+1:emgEnd+outLen,:) = out-512;
    emgEnd = emgEnd+outLen;
    pause(.05);
end

while(1)
    
    % data acquisition
    if(board.BytesAvailable)
        tic; [out, chunk] = parseEMG(fscanf(board, '%c', board.BytesAvailable), chunk);
    else
        pause(.01);
        continue;
    end
    
%     try	% simulated board
%         [out, chunk] = parseEMG(simBoard(), chunk);
%     catch e %#ok<NASGU>
%         warning('NO MORE DATA');
%         return;
%     end
    
    outLen = size(out,1);
    
    if(outLen==0)    % you're running too fast, calm down...
        pause(.025-toc);
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
    
    if DBG
        fprintf('- emgStart %d, emgEnd %d, len %d\n', emgStart, emgEnd, emgEnd-emgStart+1);
    end
    if DRAW     % printing segmentation
        low = filter(nLow, dLow, abs(emg(emgStart:emgEnd,:))); %#ok<UNRCH>
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
                
                nnRes = mySim(netStr, feat);
                if DBG
                    tNN = toc;
                end
                
                if CMPSIM  % DEBUG: test if mySim gives te same result as the original one
                    if(~all(nnRes==net(feat)))
                        save('err.mat','net','netStr','feat');
                    end
                end
                
                resp = find(nnRes>.6);
                fprintf('   %.3f', nnRes);
                fprintf('\n');
                if(~isempty(resp))
                    fprintf('gesture %d\n', resp);
                end
                
                if DBG
                    if ICA
                        fprintf(['time from last acquisition: %.3fs ' ...
                            '(ICA: %.3fs, feats: %.3fs, NN: %.3fs)\n\n'], ...
                            toc, tIca-tAn, tEx-tIca, tNN-tEx);
                    else
                        fprintf(['time from last acquisition: %.3fs ' ...
                            '(feats: %.3fs, NN: %.3fs)\n\n'], ...
                            toc, tEx-tAn, tNN-tEx);
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
        subplot(3,2,2); hold on; %#ok<UNRCH>
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