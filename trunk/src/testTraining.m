function feats = testTraining(patient)

global DBG;    % debug

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

% reordering
for ii=1:size(gest,1)
    feats{ii} = [feats{ii}{:}];
end

% dividing into training, validation and test set
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

end