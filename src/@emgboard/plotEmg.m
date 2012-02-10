function plotEmg(EB)
%

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

sig = [1 1 1];
s = 1;

fi = figure;
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
    for ii = 1:3
        subplot(3,1,ii);
        plot(1:s-e,sig(1:s-e,ii)); hold on;
        plot(s-e:s,sig(s-e:s,ii),'r');
        ylabel(sprintf('Ch%d',ii));
    end
    drawnow;
end

end