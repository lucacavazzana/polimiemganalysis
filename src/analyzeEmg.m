function feats = analyzeEmg(emg, action, gest)

PLOT = 0;

% 270/2 is the max freq we can see @270 sample/sec. This way we are cutting
% off 2Hz for signal segmentation
[b,a] = butter(2, 0.0148);	% 4/270
[d,c] = butter(2, 0.0741, 'high');	% 20/270

% preprocessing
rect = abs(emg-512); % rectifiication   FIXME: but mean value is around 524
splt = filter(b,a,rect);
% finding bursts
[head, tail] = findBurst(splt);
nBursts = length(head);

emg = filter(d,c,emg);
feats = cell(1,nBursts);

switch action
    case 'feats'    % returns emg features
        for  bb = 1:nBursts
            feats{bb} = [extractFeatures(emg(head(bb):tail(bb),1)); ...
                extractFeatures(emg(head(bb):tail(bb),2)); ...
                extractFeatures(emg(head(bb):tail(bb),3))];
        end
        
    case 'emg'  % returns raw emg
        for  bb = 1:nBursts
            feats{bb} = emg(head(bb):tail(bb),:);
        end
end

if PLOT
    clf;
    title(sprintf('%d bursts found',nBursts));
    for cc=1:3
        subplot(3,1,cc);
        hold on;
        plot(emg(:,cc));
        plot(splt(:,cc),'r','LineWidth', 2);
        plot( cumsum([3*emg(1:50,cc); emg(51:end,cc)])./(1:length(emg))', 'y');
        if (~isempty(head))
            line([head;tail],100*ones(2,nBursts),'LineWidth',3);
        end
        axis([1,length(emg),-200,200]);
        ylabel(sprintf('Ch%d',cc));
    end
    
    subplot(3,1,1);
    title(sprintf('%d bursts found',nBursts));
    if(nargin>1)
        disp(gest);
    end
    pause;
    % remember to close the figure eventually
end

end