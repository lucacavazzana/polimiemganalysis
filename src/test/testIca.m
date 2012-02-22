function testIca(folder, nNet)
%   TESTICA plots mean error and std of the classifier network with and
%   without ICA.
%   TESTICA(FNAME, NNET) loads nets and bursts from FNAME file (saved using
%   trainNN) and plots errors and std using the NNET-th net (if specified).

%   TAG: test

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

% --- error evaluation ---
err = @(y,t) (y-t)'*(y-t)/numel(y);

load('testNets.mat');   % net

if(~exist('nNet','var'))
    net = nets{1};
    testInd = trs{1}.testInd;
else
    net = nets{nNet};
    testInd = trs{nNet}.testInd;
end

burst = emgsig(emgboard.sRate);

trgt = eye(max(gest));

wIca = [];
errIca = [];
noIca = [];
errNoIca = [];

for ii = testInd
    
    burst.setSignal( ...
        bursts{ii}...
        );
    burst.findBursts;
    
    res = sim(net, burst.extractFeatures('ica'));
    wIca = cat(2, wIca, res{1});
    errIca = cat(2, errIca, err(res{1}, trgt(:,gest(ii))) );
    
    res = sim(net, burst.extractFeatures);
    noIca = cat(2,noIca,res{1});
    errNoIca = cat(2,errNoIca, err(res{1}, trgt(:,gest(ii))) );
end



errs(max(gest)) = 0;
sdev = errs;
for gg = 1:max(gest)
    errs(gg) = mean(errNoIca(gest(testInd)==gg));
    sdev(gg) = std(errNoIca(gest(testInd)==gg));
end
subplot(211);
plot(gest(testInd), errNoIca,'*'); hold on;
errorbar(1:max(gest), errs, sdev, 'ro');
ylabel('error');
xlabel('gestures');
title('without ICA');
axis tight;
legend('samples','mean (std)');

for gg = 1:max(gest)
    errs(gg) = mean(errIca(gest(testInd)==gg));
    sdev(gg) = std(errIca(gest(testInd)==gg));
end
subplot(212);
plot(gest(testInd), errIca,'*'); hold on;
errorbar(1:max(gest), errs, sdev, 'ro');
ylabel('error');
xlabel('gestures');
title('with ICA');
axis tight;
legend('samples','mean (std)');

end