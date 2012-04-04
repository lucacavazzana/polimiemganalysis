function feats = extractFeatures(EMG, varargin)
%EXTRACTFEATURES extract burst features
%   This method extracts the features (singular values of cwt, mean and
%   integral value) of the bursts found with FINDBURSTS
%
%   See also FINDBURSTS

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

nBursts = size(EMG.heads,2);
feats = cell(1, nBursts);

ICA = 0;
COMPL = 0;
for inp = varargin
    if(strcmp(inp,'ica'))
        ICA = 1;
    elseif(strcmp(inp,'compl'))
        COMPL = 1;
    end
end

if COMPL    % extract feats from the complete signal, regardless burst detection
    s = filter(EMG.nHigh, EMG.dHigh, EMG.sig);
    if ICA
        [s, EMG.a] = ica( s, [] );
    end
    feats{1} = extractFeatures(s, EMG.scales, EMG.yWAV, EMG.xWAV);
    return;
end


if (nBursts == 0)
    feats = {};
    return;
end

for bb = 1:nBursts
    
    if (EMG.tails(bb)-EMG.heads(bb)) < 120  % too small, isn't worth analyzing it
        
        if ICA  % computing weights warmup next iteration
            s = filter(EMG.nHigh, EMG.dHigh, ...
                EMG.sig(EMG.heads(bb):EMG.tails(bb),:));
            [~, EMG.a] = ica( s, EMG.a );
        
        % else nothing
        
        end
        
    else
        
        % highpass
        s = filter(EMG.nHigh, EMG.dHigh, ...
            EMG.sig(EMG.heads(bb):EMG.tails(bb),:));
        
        if ICA
            [s, EMG.a] = ica( s, EMG.a );
        end
        
        feats{bb} = extractFeatures(s, EMG.scales, EMG.yWAV, EMG.xWAV);
        
    end
    
end

end