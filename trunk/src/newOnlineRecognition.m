function [] = newOnlineRecognition(net, varargin)

clc;
close all;
fclose all;

% clear ports if still open (assuming the serial objects were tagged)
try
    fclose(instrfind('Tag','EmbBoard'));
catch e
end
try
    fclose(instrfind('Tag','Polimanus'));
catch e
end

DBG = 1;
% visual feedback for debugging. 0 none, 1 emg, 2 emg+filtered burst
DRAW = 1;

DUMMY = 1;	% use dummy emg board (1) or the real one?
PM = 0;     % 1 if Polimanus is connected

tic

ICA = 0;

if (nargin>1)
    for ii = 1:length(varargin)
        switch(varargin{ii})
            case 'ica'
                ICA = 1;
        end
    end
end

%---- OPENING BOARD PORT ------------
if DUMMY
    board = dummyboard();
else
    board = emgboard('COM6');
end
board.open('log');
%---- OPENING POLIMANUS PORT --------
if PM
    polim = polimanus();
    polim.open('log');
end
%------------------------------------

signal = emg(240);

if DRAW
    f = figure;
end

while(size(signal.sig,1) < 110)
    out = board.getEmg();
    signal.add(out);
    pause(3/board.sRate);
end

while(1)
    
    out = board.getEmg();
    if DBG
        tAcq = toc;
    end
    
    outLen = size(out,1);
    
    if(outLen == 0)    % you're running too fast, calm down...
        pause(3/board.sRate);
        continue;
    end
    
    signal.add(out);
    
    if DBG>1
        fprintf('signal length: %d\n', size(signal.sig,1));
    end
    
    nBurst = signal.findBursts();
    
    if(nBurst>0)
        
        fprintf('- got %d bursts\n', nBurst);
        
        feats = signal.extractFeatures();
        
        for ff = 1:length(feats)
            
            if(~isempty(feats{ff}))
                nnRes = sim(net, feats{ff});
                
                [~, rec] = max(nnRes.*(nnRes>.6));
                if rec
                    fprintf(' - gesture %d (', rec)
                    fprintf('   %.3f', nnRes);
                    fprintf('   ) - len: %d\n', ...
                        signal.tails(ff)-signal.heads(ff)+1);
                end
            end
        end
        
    end
    
    if DRAW
        clf(f);
        figure(f);
        for cc = 1:3
            subplot(3,1,cc); hold on;
            plot(signal.sig(:,cc));
            ylabel(sprintf('Ch%d',cc));
            axis([1,size(signal.sig,1),-512,512]);
            for bb = 1:nBurst
                plot(signal.heads(bb):signal.tails(bb), ...
                    signal.sig(signal.heads(bb):signal.tails(bb),cc), ...
                    'r');
            end
        end
        drawnow;
    end
    
    signal.clearSignal;
    
end

end