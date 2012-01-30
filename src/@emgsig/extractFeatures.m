function feats = extractFeatures(EMG, varargin)
%EXTRACTFEATURES extract burst features
%   This method extracts the features (singular values of cwt, mean value,
%   integral) of the bursts found with FINDBURSTS
%
%   See also FINDBURSTS

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

nBursts = size(EMG.heads,2);
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
    
    if (EMG.tails(bb)-EMG.heads(bb)) < 120  % too small, isn't worth analyzing it
        
        if ICA  % computing weights warmup next iteration
            s = filter(EMG.nHigh, EMG.dHigh, ...
                EMG.sig(EMG.heads(bb):EMG.tails(bb),:));
            [~, EMG.a] = ica( s, EMG.a );
        end
        
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