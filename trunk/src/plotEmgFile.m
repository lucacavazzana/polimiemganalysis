function f = plotEmgFile(patient, seq, gesID, gesName)
% PLOTEMGFILE plots EMG data from file
%   F = PLOTEMGFILE(FOLDER, SEQ, GESID, GESNAME) plots EMG signal saved in
%   files FOLDER/ch#/GESID-SEQ-GESNAME.txt and returns figure hadle.

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

f = figure('NumberTitle', 'off', ...
    'Name', sprintf('%s: %s (%d) %d', patient, gesName, gesID, seq));
for i = 1:3
    if(ispc())
        file = sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, i, gesID, seq, gesName);
    else
        file = sprintf('%s/ch%d/%d-%d-%s.txt', patient, i, gesID, seq, gesName);
    end
    fid = fopen(file, 'r');
    ch = fscanf(fid, '%d', [1 inf]);
    fclose(fid);
    subplot(3,1,i);
    plot(ch);
    axis([0, length(ch), minmax(ch)]);
    ylabel(sprintf('Ch%d',i));
end

drawnow expose;

end