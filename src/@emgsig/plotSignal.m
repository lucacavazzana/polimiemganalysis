function f = plotSignal(EMG, f)
%PLOTBURSTS plots EMG signal
%   F = PLOTSIGNAL(F) plots the emg signal highlighting the bursts in case
%   found with FINDBURST. If provided the handler F plots in the associated
%   figure (plots in a new window otherwise).
%
%   See also FINDBURSTS

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(nargin==1)
    f = figure;
end

nb = length(EMG.heads);

clf(f);
figure(f);
for cc = 1:3 
    subplot(3,1,cc); hold on;
    plot( EMG.sig(:,cc)-mean(EMG.sig(:,cc) ) );
    ylabel(sprintf('Ch%d',cc));
    xlabel('samples');
    axis([1,size(EMG.sig,1),-512,512]);
    
    if EMG.low  % if FINDBURST performed
        plot( EMG.low(:,cc), 'r' );
        
        for bb = 1:nb
            plot([EMG.heads(bb), EMG.tails(bb)], ...
                [50, 50], ...
                'g','LineWidth', 2);
            %         plot(EMG.heads(bb)*[1 1],[0,100],'g','LineWidth',2);
            %         plot(EMG.tails(bb)*[1 1],[0,100],'r','LineWidth',2);
        end
    end
end

drawnow;

end