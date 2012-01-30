function [nets, trs] = trainNN(patients, nnn, burstRatio, varargin)

% INPUTS
%    PATIENT :  patient folder name
%        NNN :  # of nets to train
% BURSTRATIO :  % of the burst to use
% OPTIONAL
%      'ica' :  performs indipendent component analysis before feature
%               extraction
%
% OUTPUTS
%       NETS :  cell array of NN
%        TRS :  cell array of training records

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

JUSTTRAIN = 0; % for debugging, if =1 skip the analysis, load the (previously) saved data and jump to the NN training
ICA = 0;
SAVERAW = 1;    % save segmented bursts (for further tests)

if(nargin < 3)
    burstRatio = 1;
    if(nargin < 2)
        nnn = 1;
    end
end

fprintf('training %d nets\nusing %.1f/100 of full bursts\n', nnn, burstRatio*100);

if (nargin > 3)
    for ii = 1:length(varargin)
        switch(varargin{ii})
            case 'ica'
                fprintf('ICA selected\n');
                ICA = 1;
        end
    end
end

if SAVERAW
    emgs = {};
    targets = [];
end


if JUSTTRAIN
    load('fullFeats.mat');
else
    
    for patient = patients
        
        % loading gesture info
        load([patient{1},'/gest.mat']);
        
        feats = cell(size(gest,1),1);
        
        % extracting bursts and features
        for gg=1:size(gest,1) % for each gesture #ok<USENS>
            
            for rr=1:gest{gg,3} % for each repetition
                emg=[];
                
                % starting from the last a Nx3 matrix is allocated, so we don't
                % have to resize adding a column every cycle
                for cc=3:-1:1
                    emg(:,cc) = convertFile2MAT(sprintf('%s/ch%d/%d-%d-%s.txt', ...
                        patient{1}, cc, gest{gg,1}, rr, gest{gg,2}));
                end
                
                if ICA
                    feats{gg} = [feats{gg} analyzeEmg(emg, 'feats', burstRatio, 'ica', 'gest', gest{gg,2})];
                else
                    feats{gg} = [feats{gg} analyzeEmg(emg, 'feats', burstRatio, 'gest', gest{gg,2})];
                end
                
                if SAVERAW
                    new = analyzeEmg(emg, 'emg', 1);
                    emgs = cat(2, emgs, new);
                    targets = cat(1, targets, gg*ones(length(new),1));
                end
                
            end
        end
    end
end

if SAVERAW
    save('newEmgs.mat','emgs','targets');
    clear emgs targets;
end

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

if(nnn>1)
    nets{nnn} = 0;  % preallocating
    trs{nnn} = 0;
end

buildResp = eye(length(gest));

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
        [net, tr] = train(net,inputs,targets);
        
        % test rate
        [~, resp] = max(net(inputs(:,tr.testInd)),[],1);
        rate = sum(all(buildResp(:,resp)==targets(:,tr.testInd))) / length(tr.testInd);
    end
    
    fprintf('net %d/%d - success rate: %.3f\n', ii, nnn, rate);
    
    nets{ii} = net;
    trs{ii}=tr;
end

end