function feats = extractFeatures(EMG, varargin)

nBursts = size(2,EMG.heads);
feats = cell(1, nBursts);

if (nBursts == 0)
    feats = {};
    return;
end

ICA = 0;
for inp = varargin
    if(strcmp(inp,'ica'))
        ICA = 1;
    end
end

for bb = 1:nBursts
    
    if (EMG.tails(bb)-EMG.heads(bb)) < 120
        
        if ICA  % computing weights speedup next iterations
            s = filter(EMG.nHigh, EMG.dHigh, ...
                EMG.sig(EMG.heads(bb):EMG.tails(bb),:));
            [~, EMG.a] = ica( s, EMG.a);
        end
        
        continue;   % too small, isn't worth analyzing it
        
    else
        s = filter(EMG.nHigh, EMG.dHigh, ...
            EMG.sig(EMG.heads(bb):EMG.tails(bb),:));
        
        if ICA
            [s, EMG.a] = ica( s, EMG.a );
        end
        
        feats{bb} = extractFeatures(s);
    end
    
end

end