function testNewFeats()
%   test using different features

%   TAG: test

close all;
clear all;

load emgsAB.mat

% r = 1 - close
% m = 2 - open
% g = 3 - ext w
% k = 4 - flex w
% y = 5 - th abd
% b = 6 - th opp
% c = 7 - index
colors = {'r','m','g','k','y','b','c'};

rawRms(length(emgs),3)=0;
rms=rawRms;
sd=rawRms;

for gg = 1:7
    
    bb = find(targets'==gg);
    for ii = bb
        w1 = cwt(emgs{ii}(:,1),1:5,'db2');
        w2 = cwt(emgs{ii}(:,2),1:5,'db2');
        w3 = cwt(emgs{ii}(:,3),1:5,'db2');

        rawRms(ii,:) = [...
            step(dsp.RMS, emgs{ii}(:,1)), ...
            step(dsp.RMS, emgs{ii}(:,2)), ...
            step(dsp.RMS, emgs{ii}(:,3))];
        
        rms(ii,:) = [...
            step(dsp.RMS, w1(:)), ...
            step(dsp.RMS, w2(:)), ...
            step(dsp.RMS, w3(:))];
        
        sd(ii,:) = [...
            step(dsp.StandardDeviation, w1(:)), ...
            step(dsp.StandardDeviation, w2(:)), ...
            step(dsp.StandardDeviation, w3(:))];
    end
end

lrms = log(rms);

disp('calcolato');

keyboard;

figure; hold on; grid on;
for ii = 1:length(emgs)
    plot3(rawRms(ii,1), rawRms(ii,2), rawRms(ii,3), ['o',colors{targets(ii)}]);
end
title('raw RMS');

figure; hold on; grid on;
for ii = 1:length(emgs)
    plot3(rms(ii,1), rms(ii,2), rms(ii,3), ['o',colors{targets(ii)}]);
end
title('RMS');

figure; hold on; grid on;
for ii = 1:length(emgs)
    plot3(lrms(ii,1), lrms(ii,2), lrms(ii,3), ['o',colors{targets(ii)}]);
end
title('logRMS');

figure; hold on; grid on;
for ii = 1:length(emgs)
    plot3(sd(ii,1), sd(ii,2), sd(ii,3), ['o',colors{targets(ii)}]);
end
title('standard deviation');

end