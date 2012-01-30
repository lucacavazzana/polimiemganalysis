function plotBursts(EMG)
%PLOTBURSTS plots found bursts
%   PLOTBURST plots the emg signal highlighting the bursts found with
%   FINDBURST.
%
%   See also FINDBURSTS

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

nb = EMG.findBursts();

f = figure;

for cc = 1:3
    subplot(3,1,cc); hold on;
    plot( abs( EMG.sig(:,cc)-mean(EMG.sig(:,cc)) ) );
    plot( EMG.low(:,cc), 'r');
    for bb = 1:nb
        plot([EMG.heads(bb), EMG.tails(bb)], ...
            [50, 50], ...
            'g','LineWidth', 2);
%         plot(EMG.heads(bb)*[1 1],[0,100],'g','LineWidth',2);
%         plot(EMG.tails(bb)*[1 1],[0,100],'r','LineWidth',2);
    end
end

drawnow;

end