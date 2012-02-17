function [nets, trs] = newTrainNN(patient, nnn, burstRatio, varargin)
% INPUTS
%    PATIENT :  patient folder name
%        NNN :  # of nets to train
% BURSTRATIO :  % of the burst to use
%
% OPTIONAL
%      'ica' :  performs indipendent component analysis before feature
%               extraction
%
% OUTPUTS
%       NETS :  cell array of NN
%        TRS :  cell array of training records

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

SAVERAW = 0;

% default values
if(nargin < 3)
    burstRatio = 1;
    if(nargin < 2)
        nnn = 1;
    end
end

fprintf('training %d nets\nusing %.1f/100 of full bursts\n', nnn, burstRatio*100);

ICA = 0;
if (nargin > 3)
    for ii = 1:length(varargin)
        switch(varargin{ii})
            case 'ica'
                fprintf('ICA selected\n');
                ICA = 1;
        end
    end
end

parsed = convertAll(patient);
emg = emgsig(emgboard.sRate);  % 237Hz last time I checked

bursts = {};
feats = {};
gest = [];

for ee = parsed'
    
    emg.setSignal(ee{1});
    
    nb = emg.findBursts;     % now find bursts!
    
    % testing
    %     if(nb~=10)
    %         emg.plotBursts;
    %         disp([emg.heads; emg.tails]);
    %         keyboard;
    %     end
    
    if SAVERAW
        bursts = cat(2, bursts, emg.getBursts);
    end
    
    if ICA
        feats = cat(2, feats, emg.extractFeatures('ica'));
    else
        feats = cat(2, feats, emg.extractFeatures());
    end
    
    gest = cat(2, gest, ee{2}*ones(1,size(emg.heads,2)));  % adding target vector
    
end

feats = cell2mat(feats);

if SAVERAW
    save('newEmgs.mat', ...
        'bursts', ...
        'feats', ...
        'gest', ...
        'burstRatio');
    clear 'bursts';
end

disp('Done parsing, now NN');

% building target matrix
targets = eye(max(gest));
targets = targets(:,gest);


% NOW THE NN PART
if(nnn>1)
    nets{nnn} = 0;  % preallocating
    trs{nnn} = 0;
end

net = patternnet(35);   % FIXME: eventually modify this parameter
% setup division of data for training, validation, testing
net.divideFcn = 'dividerand';  % divide data randomly
net.divideMode = 'sample';  % divide up every sample
net.divideParam.trainRatio = .75;
net.divideParam.valRatio = .15;
net.divideParam.testRatio = .1;
net.performFcn = 'mse';  % mean squared error

for ii = 1:nnn
    
    rate = 0;
    while(rate < .925)  % only the good ones
        
        % need to re-init weight every time, otherwise new training will
        % start from the old weights (using the whole data set for
        %training, leading to overfitting on the dataset)
        net = init(net);
        
        % train the network
        [net, tr] = train(net, feats, targets);
        
        % test rate
        [~, resp] = max( net(feats(:,tr.testInd)), [],1);
        rate = sum( resp == gest(tr.testInd) ) / length(tr.testInd);
        disp(rate);
    end
    
    fprintf('net %d/%d - success rate: %.3f\n', ii, nnn, rate);
    
    nets{ii} = net;
    trs{ii}=tr;
end

end