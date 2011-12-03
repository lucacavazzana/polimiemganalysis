% feats = testTraining();
[trSet, valSet, testSet] = splitData(feats,3/5,1/5);


% input - target matrices
in = zeros(length(feats{1}{1}),length([trSet{:}]));
tar = zeros(length(feats),length([trSet{:}]));

ii = 1;
for gg = 1:length(feats)
    nSam = length(trSet{gg});
    
    for jj = 1:nSam
        in(:,ii) = feats{gg}{trSet{gg}(jj)};
        tar(gg,ii) = 1;
        ii = ii+1;
    end
end

% validation - target matrices
val = zeros(length(feats{1}{1}),length([valSet{:}]));
valTar = zeros(length(feats),length([valSet{:}]));

ii = 1;
for gg = 1:length(feats)
    nSam = length(valSet{gg});
    
    for jj = 1:nSam
        val(:,ii) = feats{gg}{valSet{gg}(jj)};
        valTar(gg,ii) = 1;
        ii = ii+1;
    end
end

% now train the NN
% create the ANN
net=newff(in,tar,35);

% modify some network parameters (values found empirically)
v.P = val;
v.T = valTar;
net.trainParam.mu = 0.9;
net.trainParam.mu_dec = 0.8;
net.trainParam.mu_inc = 1.5;
net.trainParam.goal = 0.001;

% train the ANN
net = train(net,in,tar,{},{},v);


% testing
tentativi = 0;
successi = 0;
for gg = 1:length(feats)
    nSam = length(testSet{gg});
    
    for jj = 1:nSam
        out = sim(net, feats{gg}{testSet{gg}(jj)});
        [~, res] = max(abs(out));
        [res, gg]
        tentativi = tentativi+1;
        successi = (res == gg)+successi;
    end
end

successi/tentativi