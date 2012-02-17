function len = clearSignal(EMG)
%CLEARSIGNAL remove useless samples
%   LEN = CLEARSIGNAL() removes all stored samples except the last 100.
%   Keeps only the samples associated to a still-open burst if any. Returns
%   the length of the remaining signal.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(~isempty(EMG.heads) && ...
        (EMG.tails(end) == size(EMG.sig,1)) )   % burst still open
    
    EMG.sig = EMG.sig(EMG.heads(end):end, :); % keep only last burst
    EMG.heads = EMG.heads(end);
    EMG.tails = EMG.tails(end);
    EMG.ch = EMG.ch(end);
    EMG.low = [];
    
else
    
    if(size(EMG.sig,1)>100)
        EMG.sig = EMG.sig(end-99:end, :);
    end
    EMG.heads = [];
    EMG.tails = [];
    EMG.ch = [];
    EMG.low = [];
    
end

len = size(EMG.sig,1);

end