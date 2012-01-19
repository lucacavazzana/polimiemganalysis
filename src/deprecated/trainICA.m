function [sig, net, trainSet, testSet] = trainICA()
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
        ch1=[ch1,emgs{bb}(1:BURSTLEN,1)];
        ch2=[ch2,emgs{bb}(1:BURSTLEN,2)];
        ch3=[ch3,emgs{bb}(1:BURSTLEN,3)];
    end
    
    [s1, a1, ~] = fastica(ch1', 'verbose', 'off');
    [s2, a2, ~] = fastica(ch2', 'verbose', 'off');
    [s3, a3, ~] = fastica(ch3', 'verbose', 'off');
    
    [~,mxI] = sort(sum(abs(a1)));
    mxI = mxI(end-2:end);
    s1 = sum(s1(mxI,:))';
    
    [~,mxI] = sort(sum(abs(a2)));
    mxI = mxI(end-2:end);
    s2 = sum(s2(mxI,:))';
    
    [~,mxI] = sort(sum(abs(a3)));
    mxI = mxI(end-2:end);
    s3 = sum(s3(mxI,:))';
    
    ch = abs([ch1(:), ch2(:), ch3(:)]);
    sig{gg}.mean = mean(ch);
    sig{gg}.std = std(ch);
    sig{gg}.sig = [s1 s2 s3]*diag(sig{gg}.mean);
    
    trainSet = [trainSet, sort(trn)];	%#ok<AGROW>
end

if (nargout>3)
    j = true(size(targets));
    j(trainSet)=0;
    testSet = 1:length(targets); testSet = testSet(j);
end

% creating NN training set
for bb = length(trainSet):-1:1
    feats(:,bb) = icaFeats(emgs{trainSet(bb)}, sig);
end
buildTarget = eye(length(gest));


net = patternnet(50);
net.divideFcn = 'dividerand';	% divide data randomly
net.divideMode = 'sample';      % divide up every sample
net.divideParam.trainRatio = .75;
net.divideParam.valRatio = .25;
net.divideParam.testRatio = 0;
net.performFcn = 'mse';         % mean squared error

net = train(net, feats, buildTarget(:,targets(trainSet)));

end