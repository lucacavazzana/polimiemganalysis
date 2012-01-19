function [sig, net, trainSet, testSet] = trainICA2()
%TRAINICA
%  [SIG, NET, TRAINSET, TESTSET] = TRAINICA()
%  train a net to classify gestures using GUSSS.
%  Looks like it doesn't work
%
%   SIG :   source signals
%   NET :   set of trained NN
% TRAIN :   trian indices
%  TEST :   test indices

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

TRAINR = 1/3;	% train ratio
BURSTLEN = 270;

% pre-extracted emgs
load('emgs.mat');

trainSet = [];
for gg = 1:length(gest)
       
    bInd = find(gg==targets);	% current gest indices
    bNum = length(bInd);        % num rep
    trn = randperm(bNum);
    trn = trn(1:ceil(bNum*TRAINR))+bInd(1)-1;	% get some random indices
    
    ch1=zeros(length(emgs{1}),0);	%#ok<USENS>
    ch2=ch1;
    ch3=ch1;
    
    for bb = trn
        ch1 = [ch1, emgs{bb}(1:BURSTLEN,1)];
        ch2 = [ch2, emgs{bb}(1:BURSTLEN,2)];
        ch3 = [ch3, emgs{bb}(1:BURSTLEN,3)];
    end
    
    s1 = mean(ch1,2);
    s2 = mean(ch2,2);
    s3 = mean(ch3,2);
    
    ch = abs([ch1(:), ch2(:), ch3(:)]);
    sig{gg}.mean = mean(ch);
    sig{gg}.std = std(ch);
    sig{gg}.sig = [s1 s2 s3]*diag(sig{gg}.mean);
    
    trainSet = [trainSet, sort(trn)]; %#ok<AGROW>
end

if (nargout>3)
    j = true(size(targets));
    j(trainSet)=0;
    testSet = 1:length(targets); testSet = testSet(j);
end

buildTarget = eye(length(gest));

% creating NN training set
for bb = length(trainSet):-1:1
    try
        feats(:,bb) = icaFeats(emgs{trainSet(bb)}, sig);
    catch e
        warning('deleting element %d', trainSet(bb));
        feats(:,bb) = [];
        trainSet(bb) = [];
    end
end

net = patternnet(50);
net.divideFcn = 'dividerand';	% divide data randomly
net.divideMode = 'sample';      % divide up every sample
net.divideParam.trainRatio = .75;
net.divideParam.valRatio = .25;
net.divideParam.testRatio = 0;
net.performFcn = 'mse';         % mean squared error

net = train(net, feats, buildTarget(:,targets(trainSet)));

end