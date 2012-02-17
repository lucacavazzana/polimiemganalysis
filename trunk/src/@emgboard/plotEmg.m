function plotEmg(EB, fi)
%PLOTEMG plot current signal
%   PLOTEMG plots the current signal (in red the latest acquisition). If
%   the handler is specified plots in the associated window.

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