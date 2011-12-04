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
        feats{gg}=cell(gest{gg,3},1);
        
        for rr=1:gest{gg,3} % for each repetition
            emg=[];
            
            for cc=1:3
                f = fopen(sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, cc, gest{gg,1}, rr, gest{gg,2}));
                emg(:,cc) = fscanf(f,'%d');
                fclose(f);
                emg(end,3) = emg(end,end);  % dirty way to resize the vector to avoid reallocation in the next cycle
            end
            
            feats{gg}{rr} = analyzeEmg(emg, gest{gg,2});
            
        end
    end
    
end

% reordering
for ii=1:size(gest,1)
    feats{ii} = [feats{ii}{:}];
end

inputs = zeros(length(feats{1}{1}),length([feats{:}]));
targets = zeros(length(feats),size(inputs,2));

ii = 1;
for gg = 1:length(feats)
    nSam = length(feats{gg});
    
    for jj = 1:nSam
        inputs(:,ii) = feats{gg}{jj};
        targets(gg,ii) = 1;
        ii = ii+1;
    end
end

net = patternnet(35);   % FIXME: eventually modify this parameter

% Setup Division of Data for Training, Validation, Testing
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = .75;
net.divideParam.valRatio = .15;
net.divideParam.testRatio = .1;

net.performFcn = 'mse';  % Mean squared error

% Train the Network
[net, tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
perf.errors = gsubtract(targets,outputs);
perf.all = perform(net,targets,outputs);

% Recalculate Training, Validation and Test Performance
perf.train = perform(net, targets .* tr.trainMask{1}, outputs);
perf.val = perform(net, targets  .* tr.valMask{1}, outputs);
perf.test = perform(net, targets  .* tr.testMask{1}, outputs);

if TESTNET
    
    succ = 0;
    tot = 0;
    
    for ii = find(tr.testMask{1}(1,:)==1 | tr.testMask{1}(1,:)==0)
        [~, res] = max(sim(net,inputs(:,ii)));
        succ = succ+(res==find(targets(:,ii)));
        tot=tot+1;
    end
    
    fprintf('success rate %.2f%% over %d test sets\n', succ/tot*100, tot);
    
end


return;

% % old code
% % useless to split, 'train' does it by hitself
% % dividing into training, validation and test set
% [trSet, valSet, testSet] = splitData(feats,3/5,1/5);
% 
% 
% % input - target matrices
% inputs = zeros(length(feats{1}{1}),length([trSet{:}]));
% targets = zeros(length(feats),length([trSet{:}]));
% 
% ii = 1;
% for gg = 1:length(feats)
%     nSam = length(trSet{gg});
%     
%     for jj = 1:nSam
%         inputs(:,ii) = feats{gg}{trSet{gg}(jj)};
%         targets(gg,ii) = 1;
%         ii = ii+1;
%     end
% end
% 
% % validation - target matrices
% val = zeros(length(feats{1}{1}),length([valSet{:}]));
% valTar = zeros(length(feats),length([valSet{:}]));
% 
% ii = 1;
% for gg = 1:length(feats)
%     nSam = length(valSet{gg});
%     
%     for jj = 1:nSam
%         val(:,ii) = feats{gg}{valSet{gg}(jj)};
%         valTar(gg,ii) = 1;
%         ii = ii+1;
%     end
% end
% 
% % now train the NN
% % create the ANN
% if ( sscanf(version('-release'),'%d')<2010 || ...
%         strcmp(version('-release'),'2010a') )  % NN tolboox updated between r2010a and r2010b
%     net = newff(in,tar,35);
% else
%     net = feedforwardnet(35);
% end
% 
% % modify some network parameters (values found empirically)
% v.P = val;
% v.T = valTar;
% net.trainParam.mu = 0.9;
% net.trainParam.mu_dec = 0.8;
% net.trainParam.mu_inc = 1.5;
% net.trainParam.goal = 0.001;
% 
% % train the ANN
% net = train(net,in,tar,{},{},v);

end