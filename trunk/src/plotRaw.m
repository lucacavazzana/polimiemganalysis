function plotRaw(filename)

file = fopen(filename);
data = fscanf(file ,'%c',inf);

fclose(file);

ch = emgboard.parser(data);

figure;
for cc = 1:3
    subplot(3,1,cc);
    plot(ch(:,cc));
    ylabel(sprintf('Ch%d',cc));
end

end