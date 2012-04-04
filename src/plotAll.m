function plotAll(folder, findB)
%PLOTALL    plot all acquisitions
%   PLOTALL(FOLDER, FINDBURST) plots all acquisitions in FOLDER. If
%   findburst exist and ~=0 the signal is segmented too.
%
%   TAGS: utility

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(~exist('findB','var'))
    findB = 0;
end

% get file paths
parsed = convertAll(folder);

sig = emgsig(emgboard.sRate);

f=figure;
for ii = 1:length(parsed)
    clf(f);
    sig.setSignal(parsed{ii,1});
    
    if findB    % SEGMENTATION HERE
        sig.newFindBursts();
    end
    
    sig.plotSignal(f);
    subplot(311);
    title(sprintf('file %d, gest %d', ii, parsed{ii,2}));
    fprintf('file %d, gest %d.\nPress a key to continue\n', ii, parsed{ii,2});
    pause;
end

close(f);

end