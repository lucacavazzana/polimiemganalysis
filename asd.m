function asd
patient = 'asd';
load([patient,'\gest.mat']);

fig=figure;
for ii=1:size(gest,1)
    for jj=1:gest{ii,3}
        f1 = fopen(sprintf('%s\\ch1\\%d-%d-%s.txt', patient, gest{ii,1}, jj, gest{ii,2}));
        f2 = fopen(sprintf('%s\\ch2\\%d-%d-%s.txt', patient, gest{ii,1}, jj, gest{ii,2}));
        f3 = fopen(sprintf('%s\\ch3\\%d-%d-%s.txt', patient, gest{ii,1}, jj, gest{ii,2}));
        
        emg = fscanf(f1,'%d');
        fclose(f1);
        clf(fig);
        subplot(3,1,1);
        plot(emg);
        
        emg = fscanf(f2,'%d');
        fclose(f2);
        subplot(3,1,2);
        plot(emg);
        
        emg = fscanf(f3,'%d');
        fclose(f3);
        subplot(3,1,3);
        plot(emg);
        
        drawnow;
        pause;
    end
end

end