function [net, perf, tr] = trainNN(patient)

global DBG;    % debug
JUSTTRAIN = 0; % for debugging, if =1 skip the analysis, load the saved data and jump to the NN part
TESTNET = 1; % if 1 test on gesture recognition is performed

if JUSTTRAIN
    load('feats.mat');
else
    
    if DBG
        patient = 'asd';
    end
    
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
            
            for cc=1:3
                emg(:,cc) = convertFile2MAT(sprintf('%s\\ch%d\\%d-%d-%s.txt', ...
                    patient, cc, gest{gg,1}, rr, gest{gg,2}));
                emg(end,3) = emg(end,end);  % dirty way to resize the vector to avoid reallocation in the next cycle
            end
            
            feats{gg} = [feats{gg} analyzeEmg(emg, 'feats', gest{gg,2})];
            
        end
    end
    
end

clear emg;

% training the net now
inputs = cell2Mat([feats{:}]);
targets = zeros(length(feats), size(inputs,2));

ii = 0;
for gg = 1:length(feats)
    nSam = size(feats{gg},2);
    
    targets(gg, ii+1:ii+nSam) = 1;
    ii = ii+nSam;
end

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

% test the network
if nargout>1
    outputs = net(inputs);
    perf.errors = gsubtract(targets,outputs);
    perf.all = perform(net,targets,outputs);
    
    % recalculate training, validation and test performance
    perf.train = perform(net, targets .* tr.trainMask{1}, outputs);
    perf.val = perform(net, targets  .* tr.valMask{1}, outputs);
    perf.test = perform(net, targets  .* tr.testMask{1}, outputs);
end

% testing using the test set
if TESTNET
    
    succ = 0;
    tot = 0;
    
    for ii = tr.testInd
        [~, res] = max(sim(net,inputs(:,ii)));
        succ = succ+(res==find(targets(:,ii)));
        tot=tot+1;
    end
    
    fprintf('success rate %.2f%% over %d test sets\n', succ/tot*100, tot);
    
end

end