function ch = plotRaw(filename)
%PLOTRAW    plot signal in raw file data
%   CH = PLOTRAW(FILENAME) plots the unparsed signal stored in FILENAME.
%   Returns also CH, the signal matrix.
%
%   TAGS: utility

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

file = fopen(filename);
data = fscanf(file,'%c',inf);

fclose(file);

ch = emgboard.parser(data);

figure;
for cc = 1:3
    subplot(3,1,cc);
    plot(ch(:,cc));
    ylabel(sprintf('Ch%d',cc));
end

end