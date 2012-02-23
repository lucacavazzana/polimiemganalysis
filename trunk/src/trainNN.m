function [nets, trs] = trainNN(folder, nnn, burstRatio, varargin)
% INPUTS
%     FOLDER :  patient folder name
%        NNN :  # of nets to train
% BURSTRATIO :  % of the burst to use
%
% OPTIONAL
%      'ica' :  performs indipendent component analysis before feature
%               extraction
%     'plot' :  plots segmented signal for debug
%
% OUTPUTS
%       NETS :  cell array of NN
%        TRS :  cell array of training records

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

PLOT = 0;
fig = 0;

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
                
            case 'plot'
                PLOT = 1;
        end
    end
end

parsed = convertAll(folder);
emg = emgsig(emgboard.sRate);  % 237Hz last time I checked

bursts = {};
feats = {};
gest = [];

for ee = parsed'
    
    emg.setSignal(ee{1});
    
    nb = emg.findBursts;     % now find bursts!
    
    if PLOT
        if fig == 0
            fig = figure;
        end
        emg.plotSignal(fig);
        pause();
    end
    
    % testing
    %     if(nb~=10)
    %         emg.plotBursts;
    %         disp([emg.heads; emg.tails]);
    %         keyboard;
    %     end
    
    bursts = cat(2, bursts, emg.getBursts);
    
    if ICA
        feats = cat(2, feats, emg.extractFeatures('ica'));
    else
        feats = cat(2, feats, emg.extractFeatures());
    end
    
    gest = cat(2, gest, ee{2}*ones(1,size(emg.heads,2)));  % adding target vector
    
end

if PLOT
    close(fig)
end

feats = cell2mat(feats);

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
keyboard
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
%         disp(rate);
    end
    
    fprintf('net %d/%d - success rate: %.3f\n', ii, nnn, rate);
    
    nets{ii} = net;
    trs{ii}=tr;
end

% dumping on disk
name = sprintf('%s/newNets.mat', folder);
ii = 1;
while(exist(name,'file'))
    name = sprintf('%s/newNets%d.mat', folder, ii);
    ii = ii+1;
end

save(name, ...
    'bursts', ...
    'feats', ...
    'gest', ...
    'burstRatio', ...
    'nets', ...
    'trs');

end