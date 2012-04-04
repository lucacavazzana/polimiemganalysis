function saveBursts(type, folder)
%SAVEDATA save raw bursts or features on disk
%   SAVEBURST(TYPE, FOLDER) extracts bursts from the files into FOLDER/ch#
%   and save the raw data (TYPE = 'raw') or their features (TYPE = 'feats')
%   into 'folder_type.mat'.
%   The file will contain a 2xN cell matrix, on the first row the
%   signal/features, on the second one the gesture ID.
%
%   TAG: utility

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

switch type
    case 'raw', type = 0;
    case 'feats', type = 1;
    otherwise, error('unknown parameter "%s"', type);
end

if(~exist(folder,'dir'))
    error('can''t find "%s" folder', folder);
end

parsed = convertAll(folder);

sig = emgsig(emgboard.sRate);
out = {};

for ss = parsed'
    sig.setSignal(ss{1});
    nn = sig.findBursts;
    
    if nn>0
        if type     % FEATS
            bb = sig.extractFeatures;
        else    % RAW
            bb = sig.getBursts;
        end
        
        for ii = 1:length(bb)
            bb{2,ii} = ss{2};
        end
        
        out = cat(2,out,bb);
    end
    
end

% renaming
if type %FEATS
    feats = out;
    save(sprintf('%s_feats.mat',folder),'feats');
else % raw
    raw = out;
    save(sprintf('%s_raw.mat',folder),'raw');
end

end