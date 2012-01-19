function [U] = testEigenEMG()
% testing PCA
% http://math.loyola.edu/reports/tr2009_01.pdf
% http://www.pages.drexel.edu/~sis26/Eigenface%20Tutorial.htm

NEIG = 10;  % number of eigenvector to consider

load emgsA.mat
% 
% for ii=1:length(emgs)
%     emgs{ii} = abs(emgs{ii});
% end

sig1 = [];
sig2 = [];
sig3 = [];

trainSet = [];
testSet = [];

for gg = 1:7
    bb = find(targets'==gg);
    [trn, tst] = getTrain(bb, .7);
    
    trainSet = cat(2, trainSet, bb(trn));
    testSet = cat(2, testSet, bb(tst));
    
    for  burst=emgs(trn)    % for each gesture
        
        w1 = cwt(burst{1}(51:150,1),1:5,'db4')';
        w2 = cwt(burst{1}(51:150,2),1:5,'db4')';
        w3 = cwt(burst{1}(51:150,3),1:5,'db4')';
        
        sig1 = cat(2,sig1,w1(:));
        sig2 = cat(2,sig2,w2(:));
        sig3 = cat(2,sig3,w3(:));
    end
end

[U1,~,~] = svd(sig1);
[U2,~,~] = svd(sig2);
[U3,~,~] = svd(sig3);

U = cat(3,U1(:,1:NEIG)',U2(:,1:NEIG)',U3(:,1:NEIG)');
fprintf('SVD computed\n');

feats(3*(NEIG+2), length(emgs)) = 0; % preallocating

for ii = 1:length(emgs)
    w1 = cwt(emgs{ii}(51:150,1), 1:5, 'db4')';
    w2 = cwt(emgs{ii}(51:150,2), 1:5, 'db4')';
    w3 = cwt(emgs{ii}(51:150,3), 1:5, 'db4')';
    
    proj1 = U1(:,1:NEIG)' * w1(:);
    proj2 = U2(:,1:NEIG)' * w2(:);
    proj3 = U3(:,1:NEIG)' * w3(:);
    
    feats(:,ii) = [proj1; proj2; proj3; ...
        step(dsp.RMS,emgs{ii}(51:150,:))'; ... RMS for each channel
        mean(abs(w1(:)-U1(:,1:NEIG)*proj1)); ... reconstruction error
        mean(abs(w2(:)-U2(:,1:NEIG)*proj2)); ...
        mean(abs(w3(:)-U3(:,1:NEIG)*proj3))];
    
%     clf;
%     subplot(3,1,1);
%     plot([w1(:),U1(:,1:NEIG)*proj1]);
%     subplot(3,1,2);
%     plot([w2(:),U2(:,1:NEIG)*proj2]);
%     subplot(3,1,3);
%     plot([w3(:),U3(:,1:NEIG)*proj3]);
%     fprintf('mean error: %f\n', mean(abs(w3(:)-U3(:,1:NEIG)*proj3)));
%     pause;
end

keyboard;

% computing mean and std for each gesture
for gg = 1:7
    bb = trainSet(targets(trainSet)==gg);
    
    m(:,gg) = mean(feats(:,bb),2);
    s(:,gg) = std(feats(:,bb),1,2);
end

% check vs test set
for gg = 1:7
    bb = testSet(targets(testSet)==gg);
    
    fprintf('\n%d: ', gg);
    
    for ii = bb
        
        r = sum(((feats(:,ii*ones(1,7))-m)./s).^2,1);
        [~, ri] = min(r);
        
        fprintf('%d ', ri);
    end
end

save tmp.mat;

end