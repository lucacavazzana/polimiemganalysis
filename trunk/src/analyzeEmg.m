function [feats] = analyzeEmg(emg, action, burstRatio, varargin)
%ANALYZEEMG
% INPUT
%           EMG :	raw emg data (expects a values within 0-1024)
%        ACTION :   'feats' if yout want the computed features
%                   'emg' if you want the raw burst emg
%    BURSTRATIO :   if < 1 analyze only the initiali value% of the signal
%
% OPTIONAL
%         'ica' :   performs indipendent compnent analysis before features
%                   extraction
%        'gest' :   followed by gesture name string (for fancy debugging
%                   plots)
%
% OUTPUT
%         FEATS :   raw emg data or features vector (according to ACTION)

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

PLOT = 0;   % DBG

ICA = 0;
if(nargin>3)
    for ii = 1:length(varargin)
        switch varargin{ii}
            case 'ica'
                ICA = 1;
            case 'gest'
                gest = varargin{ii+1}; %#ok<NASGU>
        end
    end
end

% FIXME: not so sure is 270
% 270/2 is the max freq we can see @270 sample/sec. This way we are cutting
% off 2Hz for signal segmentation
[nLow,dLow] = butter(2, 0.0148);	% 4/270
[nHigh,dHigh] = butter(2, 0.0741, 'high');	% 20/270

% preprocessing
rect = abs(emg-512); % rectification   FIXME: but mean value is around 524
splt = filter(nLow,dLow,rect);    % lowpass for segmentation
% finding bursts
[head, tail] = findBurst(splt);
nBursts = length(head);

emg = filter(nHigh,dHigh,emg);
feats = cell(1,nBursts);

if (exist('burstRatio','var') && ~isempty(burstRatio) && burstRatio<1)
    tail = head + floor((tail-head)*burstRatio);
end

switch action
    case 'feats'    % returns emg features
        
        if ICA
            for bb = 1:nBursts
                feats{bb} = extractFeatures( ica(emg(head(bb):tail(bb),:)) );
            end
        else
            for bb = 1:nBursts
                feats{bb} = extractFeatures(emg(head(bb):tail(bb),:));
            end
        end
        
    case 'emg'  % returns raw emg
        for bb = 1:nBursts
            feats{bb} = emg(head(bb):tail(bb),:);
        end
end

if PLOT
    clf;
    title(sprintf('%d bursts found',nBursts));
    for cc=1:3
        subplot(3,1,cc);
        hold on;
        plot(emg(:,cc));
        plot(splt(:,cc),'r','LineWidth', 2);
        plot( cumsum([3*emg(1:50,cc); emg(51:end,cc)])./(1:length(emg))', 'y');
        if (~isempty(head))
            line([head;tail],100*ones(2,nBursts),'LineWidth',3);
        end
        axis([1,length(emg),-200,200]);
        ylabel(sprintf('Ch%d',cc));
    end
    
    subplot(3,1,1);
    title(sprintf('%d bursts found',nBursts));
    if(exist('gest','var'))
        disp(gest);
    end
    pause;
    % remember to close the figure eventually
end

end