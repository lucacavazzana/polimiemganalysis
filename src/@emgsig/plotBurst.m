function plotBurst( EMG, ind, f )
%PLOTBURST plots the i-th burst detected
%   PLOTBURST(II, F) plots the II-th burst detected (if exists) into figure
%   F (if provided).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

assert(ind>0);

if(ind>length(EMG.heads))
    return;
end

if(nargin<3)
    f = figure;
end
% keyboard;
clf(f);
figure(f)
for cc = 3:-1:1
    
    subplot(3,1,cc);
    plot(EMG.heads(ind):EMG.tails(ind), ...
        EMG.sig(EMG.heads(ind):EMG.tails(ind), cc)-512);
    ylabel(sprintf('Ch%d',cc));
    axis([EMG.heads(ind), EMG.tails(ind), -512, 512]);
    
end

drawnow;

end