function plotAll(folder)
%PLOTALL plot all acquisitions
%   PLOTALL(FOLDER) plots all acquisitions in FOLDER

parsed = convertAll(folder);

sig = emgsig(emgboard.sRate);

f=figure;
for ii = 1:length(parsed)
    clf(f);
    sig.setSignal(parsed{ii,1});
    sig.plotSignal(f);
    subplot(311);
    title(sprintf('file %d, gest %d', ii, parsed{ii,2}));
    pause;
end

close(f);

end