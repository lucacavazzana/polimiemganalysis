function [] = onlineRecognition(net, varargin)
%ONLINERECOGNITION
%   NET : classification net

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com

DBG = 1;
DRAW = 0;   % visual feedback for debugging. 0 none, 1 emg, 2 emg+filtered burst
DUMMY = 0;	% use dummy emg board (1) or the real one?
PM = 0;     % 1 if Polimanus is connected

clc;
close all;
fclose all;

for ii = 1:length(varargin)
    switch(varargin{ii})
        case 'plot'
            DRAW = 1;
            
    end
end

% converting to ad-hoc emgnet classificator
if(strcmp(net,'network'))
    net = emgnet(net);
    assert(strcmp(net,'emgnet'));
end

% clear ports if still open (assuming the serial objects were tagged)
try
    fclose(instrfind('Tag','EmbBoard'));
catch e
end
try
    fclose(instrfind('Tag','Polimanus'));
catch e
end

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
    dump = 'dumpboard.txt';
    ii = 0;
    while(exist(dump,'file'))
        ii = ii+1;
        dump = sprintf('dumpboard%d.txt', ii);
    end
    board = emgboard('COM6', dump);
end
board.open('log');
%---- OPENING POLIMANUS PORT --------
if PM
    polim = polimanus();
    polim.open('log');
end
%------------------------------------

signal = emgsig(emgboard.sRate);

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
        
        if ICA
            feats = signal.extractFeatures('ica');
        else
            feats = signal.extractFeatures();
        end
        
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
                
                if PM
                    switch max(rec)
                        case 1 % close hand
                            polim.moveClose();
                            disp('Closing hand');
                            
                        case 2 % open hand
                            polim.moveOpen();
                            disp('Opening hand');
                            
                        case 7 % I know, technically is index... pretend it's pinch
                            polim.movePinch();
                            disp('Pinching');
                    end
                end
            end
        end
    else
        rec = 0;
    end
    
    if DRAW
        clf(f);
        figure(f);
        subplot(3,2,[1 3 5]); hold on;
        title(sprintf('Recognized: %d',rec));
        if(nBurst)
            plot(signal.low(:,signal.ch(end)));
            plot(signal.heads(end):signal.tails(end),...
                signal.low(signal.heads(end):signal.tails(end),signal.ch(end)),'r');
        else
            plot(1,50); % that's only to rescale
            plot(max(signal.low,[],2))
        end
        for cc = 1:3
            subplot(3,2,2*cc); hold on;
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