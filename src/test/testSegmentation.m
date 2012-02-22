function testSegmentation(folder)
%   Visually check segmentation performances

%	TAG: test


if (nargin == 0)
    folder = 'asd';
end

emgs = convertAll(folder);

sig = emgsig(emgboard.sRate);
fnames = dir(sprintf('%s/*.txt',folder));
ii = 1;

if(size(fnames)~=size(emgs))
    fnames = [];
end

f = figure;
for asd = emgs'
    
    sig.setSignal(asd{1}-512);
    sig.findBursts();
    
    sig.plotSignal(f);
    
    if(~isempty(fnames))
        subplot(311);
        title(fnames(ii).name);
        ii = ii+1;
    end
    
    pause;
end

close;

end