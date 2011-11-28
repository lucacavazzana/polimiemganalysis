function f = plotEmg(ch, f, plotTitle)

if(~exist('f','var'))
    f = figure;
end
if(~exist('plotTitle','var'))
    plotTitle = 'EMG acqusition';
end

set(f, ...
    'NumberTitle', 'off', ...
    'Name', plotTitle);

subplot(3,1,1);
plot(ch(:,1));
ylabel(sprintf('Ch1'));
subplot(3,1,2);
plot(ch(:,2));
ylabel(sprintf('Ch2'));
subplot(3,1,3);
plot(ch(:,3));
ylabel(sprintf('Ch3'));

end