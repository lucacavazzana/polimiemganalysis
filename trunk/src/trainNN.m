function [nets, trs] = trainNN(patient, nnn)

% INPUTS
%   PATIENT :   patient folder name
%       NNN :   # of nets to train
%
% OUTPUTS
%      NETS :   vector of NN

global DBG;    % debug
JUSTTRAIN = 0; % for debugging, if =1 skip the analysis, load the saved data and jump to the NN part
BURSTRATIO = 1;  % percentage of the burst we are using to train the NN

if JUSTTRAIN
    load('fullFeats.mat');
else
    
    % loading gesture info
    if(ispc())
        load([patient,'\gest.mat']);
    else
        load([patient,'/gest.mat']);
    end
    
    feats = cell(size(gest,1),1);
    
    % extracting bursts and features
    for gg=1:size(gest,1) % for each gesture #ok<USENS>
        
        for rr=1:gest{gg,3} % for each repetition
            emg=[];
            
            % starting from the last a Nx3 matrix is allocated, so we don't
            % have to resize adding a column every cycle
            for cc=3:-1:1
                emg(:,cc) = convertFile2MAT(sprintf('%s\\ch%d\\%d-%d-%s.txt', ...
                    patient, cc, gest{gg,1}, rr, gest{gg,2}));
            end
            
            feats{gg} = [feats{gg} analyzeEmg(emg, 'feats', BURSTRATIO, gest{gg,2})];
            
        end
    end
    
end
keyboard
clear emg;

% training the net now
inputs = cell2mat([feats{:}]);
targets = zeros(length(feats), size(inputs,2));

% building target matrix
ii = 0;
for gg = 1:length(feats)
    nSam = size(feats{gg},2);
    
    targets(gg, ii+1:ii+nSam) = 1;
    ii = ii+nSam;
end

if(nargin<2)
    nnn=1;
end

if(nnn>1)
    nets{nnn} = 0;  % preallocating
    trs{nnn} = 0;
end

buildResp = eye(length(gest));

for ii = 1:nnn
    
    rate = 0;
    while(rate < .925)
        
        net = patternnet(35);   % FIXME: eventually modify this parameter
        
        % setup division of data for training, validation, testing
        net.divideFcn = 'dividerand';  % divide data randomly
        net.divideMode = 'sample';  % divide up every sample
        net.divideParam.trainRatio = .75;
        net.divideParam.valRatio = .15;
        net.divideParam.testRatio = .1;
        
        net.performFcn = 'mse';  % mean squared error
        
        % train the network
        [net, tr] = train(net,inputs,targets);
        
        % test rate
        [~, resp] = max(net(inputs(:,tr.testInd)),[],1);
        rate = sum(all(buildResp(:,resp)==targets(:,tr.testInd))) / length(tr.testInd);
    end
    
    if DBG
        fprintf('net %d/%d - success rate: %.3f\n', ii, nnn, rate);
    end
    
    nets{ii} = net;
    trs{ii}=tr;
end

end