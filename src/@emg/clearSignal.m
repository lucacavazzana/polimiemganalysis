function len = clearSignal(EMG)
% trash all but the last open burst burst

if(~isempty(EMG.heads) && ...
        (EMG.tails(end) == size(EMG.sig,1)) )   % burst still open
    
    EMG.sig = EMG.sig(EMG.heads(end):end, :); % keep only last burst
    
else
    
    EMG.sig = EMG.sig(end-100:end, :);
    
end

len = size(EMG.sig,1);

end