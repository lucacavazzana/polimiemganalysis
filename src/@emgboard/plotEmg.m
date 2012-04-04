function plotEmg(EB, fi)
%PLOTEMG real-time signal plot
%   F = EB.PLOTEMG(F) plots the signal from the EMG board. It takes as
%   parameter (optional) and returns the handler F of the window where the
%   signal is drawn. The signal from the latest acquisition is plotted in
%   red.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

sig = [1 1 1];
s = 1;

if(nargin == 1)
    fi = figure;
end

while(1)
    
    emg = EB.getEmg(1);
    e = size(emg,1);
    
    if(s > 100)
        sig = cat(1,sig(end-100:end,:),emg-512);
    else
        sig = cat(1,sig,emg-512);
    end
    
    s = size(sig,1);
    
    clf(fi);
    for cc = 1:3
        subplot(3,1,cc);
        plot(1:s-e,sig(1:s-e,cc)); hold on;
        plot(s-e:s,sig(s-e:s,cc),'r');
        ylabel(sprintf('Ch%d',cc));
        xlabel('samples');
        axis([1,s,-512,512]);
    end
    drawnow;
end

end